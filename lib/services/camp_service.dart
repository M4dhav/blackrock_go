import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/camp.dart';
import 'crypto_service.dart';
import 'mesh_message_service.dart';

/// Manages camp membership, join flow, and app-layer key distribution.
///
/// Join flow:
///   1. User scans camp QR  → [fromQrPayload] creates a pending Camp
///   2. App sends a join request DM to the camp gateway node
///   3. Camp lead approves via their app
///   4. Gateway node sends an encrypted DM containing group + location keys
///   5. [handleKeyDelivery] stores keys in secure storage, activates camp
class CampService extends GetxService {
  final _crypto   = Get.find<CryptoService>();
  final _db       = Get.find<Database>();
  final _uuid     = const Uuid();

  final RxList<Camp> camps = <Camp>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadCamps();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadCamps() async {
    final rows = await _db.query('camps');
    final loaded = <Camp>[];
    for (final row in rows) {
      final camp = Camp.fromMap(row);
      final memberRows = await _db.query(
        'camp_members',
        where: 'camp_id = ?',
        whereArgs: [camp.id],
      );
      camp.members = memberRows.map(CampMember.fromMap).toList();
      loaded.add(camp);
    }
    camps.assignAll(loaded);
  }

  Future<void> _persistCamp(Camp camp) async {
    await _db.insert('camps', camp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _persistMember(CampMember member) async {
    await _db.insert('camp_members', member.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Creating a camp (lead flow) ───────────────────────────────────────────

  /// Create a new camp. Generates the channel PSK and app-layer keys.
  /// Returns the camp — call [camp.toQrPayload()] to generate the join QR.
  Future<Camp> createCamp(
    String name, {
    int meshtasticSlot = 1,
    double? latitude,
    double? longitude,
    String? gatewayNodeId,
  }) async {
    final id         = _uuid.v4();
    final channelPsk = await _crypto.generateSymmetricKey();
    final groupKey   = await _crypto.generateSymmetricKey();
    final locKey     = await _crypto.generateSymmetricKey();

    await _crypto.storeCampGroupKey(id, groupKey);
    await _crypto.storeCampLocationKey(id, locKey);

    final camp = Camp(
      id: id,
      name: name,
      meshtasticSlot: meshtasticSlot,
      channelPsk: channelPsk,
      gatewayNodeId: gatewayNodeId,
      latitude: latitude,
      longitude: longitude,
      role: CampRole.lead,
      joinedAt: DateTime.now(),
    );

    await _persistCamp(camp);
    camps.add(camp);
    return camp;
  }

  // ── Joining a camp (member flow) ──────────────────────────────────────────

  /// Step 1: Parse QR, create pending camp, send join request DM.
  Future<Camp> initJoinFromQr(String qrPayload, String myDisplayName) async {
    final camp = Camp.fromQrPayload(qrPayload);
    await _persistCamp(camp);
    camps.add(camp);

    // Send join request to gateway node via mesh DM
    final myPubKey = await _crypto.getNodePublicKey();
    final request  = jsonEncode({
      'type': 'camp_join_request',
      'camp_id': camp.id,
      'display_name': myDisplayName,
      'public_key': base64Encode(myPubKey),
    });

    if (camp.gatewayNodeId != null) {
      await Get.find<MeshMessageService>()
          .sendDm(camp.gatewayNodeId!, request);
    }
    return camp;
  }

  /// Step 2: Camp lead approves a member request by member ID.
  /// Looks up the member in the roster (must have been added on join request receipt),
  /// encrypts and sends group + location keys.
  Future<void> approveMember(String campId, String memberId) async {
    final camp = camps.firstWhereOrNull((c) => c.id == campId);
    final member = camp?.members.firstWhereOrNull((m) => m.id == memberId);
    if (camp == null || member == null || member.publicKey == null) return;

    final groupKey = await _crypto.loadCampGroupKey(campId);
    final locKey   = await _crypto.loadCampLocationKey(campId);
    if (groupKey == null || locKey == null) return;

    final sharedSecret = await _crypto.deriveSharedSecretWithNodeKey(member.publicKey!);
    final payload = jsonEncode({
      'type': 'camp_key_delivery',
      'camp_id': campId,
      'group_key': base64Encode(groupKey),
      'location_key': base64Encode(locKey),
    });

    final encrypted = await _crypto.encrypt(
      sharedSecret,
      Uint8List.fromList(utf8.encode(payload)),
    );

    await Get.find<MeshMessageService>()
        .sendDm(member.nodeId, base64Encode(encrypted));

    await _persistMember(member);
    camps.refresh();
  }

  /// Leave a camp — deletes keys and removes from local DB.
  Future<void> leaveCamp(String campId) async {
    await _crypto.deleteCampKeys(campId);
    await _db.delete('camp_members', where: 'camp_id = ?', whereArgs: [campId]);
    await _db.delete('camps', where: 'id = ?', whereArgs: [campId]);
    camps.removeWhere((c) => c.id == campId);
  }

  /// Step 3: Member receives encrypted key delivery DM and activates camp.
  Future<void> handleKeyDelivery(String campId, String encryptedB64) async {
    final encrypted   = base64Decode(encryptedB64);
    // We derive shared secret using our node key + sender's public key.
    // The sender is the gateway — their pub key was in the original QR as
    // the gatewayNodeId's known identity. For now use the camp gateway's
    // public key from the mesh node info store.
    // TODO: wire gateway public key retrieval from MeshtasticNodeController
    // For now, this is a placeholder — see mesh_message_service for the
    // incoming DM routing that calls this method.
    // ignore: unused_local_variable — wired when gateway pub key retrieval is implemented
    final pending = encrypted;
  }

  // ── Message encryption / decryption ──────────────────────────────────────

  /// Encrypt a camp message payload before sending on Meshtastic channel.
  Future<String?> encryptCampMessage(String campId, String plaintext) async {
    final key = await _crypto.loadCampGroupKey(campId);
    if (key == null) return null;
    final encrypted = await _crypto.encrypt(
      key,
      Uint8List.fromList(utf8.encode(plaintext)),
    );
    return base64Encode(encrypted);
  }

  /// Decrypt an incoming camp channel message. Returns null if wrong key.
  Future<String?> decryptCampMessage(String campId, String encryptedB64) async {
    final key = await _crypto.loadCampGroupKey(campId);
    if (key == null) return null;
    final plain = await _crypto.decrypt(key, base64Decode(encryptedB64));
    if (plain == null) return null;
    return utf8.decode(plain);
  }

  /// Encrypt a position packet for camp location sharing.
  Future<String?> encryptPosition(
    String campId,
    double lat,
    double lon,
  ) async {
    final key = await _crypto.loadCampLocationKey(campId);
    if (key == null) return null;
    final payload = jsonEncode({'lat': lat, 'lon': lon, 't': DateTime.now().millisecondsSinceEpoch});
    final encrypted = await _crypto.encrypt(
      key,
      Uint8List.fromList(utf8.encode(payload)),
    );
    return base64Encode(encrypted);
  }

  /// Decrypt an incoming position packet. Returns null if wrong key.
  Future<Map<String, dynamic>?> decryptPosition(
    String campId,
    String encryptedB64,
  ) async {
    final key = await _crypto.loadCampLocationKey(campId);
    if (key == null) return null;
    final plain = await _crypto.decrypt(key, base64Decode(encryptedB64));
    if (plain == null) return null;
    return jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
  }

  // ── Lookup ────────────────────────────────────────────────────────────────

  Camp? findById(String id) => camps.firstWhereOrNull((c) => c.id == id);
}
