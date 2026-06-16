import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/location_link.dart';
import 'crypto_service.dart';
import 'mesh_message_service.dart';

/// Manages ephemeral location-sharing links between strangers.
///
/// Full flow:
///   Initiator: generateQr() → shows QR on screen (valid 5 min)
///   Responder: acceptFromQr(payload) → DH, sends acceptance DM
///   Initiator: handleAcceptance(dm) → DH, link becomes active
///   Both:      sendPosition() every 60s via encrypted DM
///   Either:    revoke(id) → sends revocation, deletes keys
class LocationLinkService extends GetxService {
  final _crypto = Get.find<CryptoService>();
  final _db     = Get.find<Database>();
  final _uuid   = const Uuid();
  final _random = Random.secure();

  final RxList<LocationLink> activeLinks = <LocationLink>[].obs;

  // Consumed nonces — prevents QR replay within session
  final _usedNonces = <int>{};

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLinks();
    _startExpiryTimer();
  }

  // ── Initiator flow ────────────────────────────────────────────────────────

  /// Generate a QR payload for sharing. Caller displays this as a QR code.
  /// The QR is valid for 5 minutes and single-use.
  Future<({String linkId, String qrJson, LinkQrPayload payload})> generateQr({
    String? myDisplayName,
    int durationMinutes = 120,
    bool bidirectional = true,
  }) async {
    final linkId    = _uuid.v4();
    final keyPair   = await _crypto.generateEphemeralKeyPair();
    final pubKey    = await keyPair.extractPublicKey();
    final myNodeId  = 'me'; // TODO: wire from MeshtasticNodeController
    final nonce     = _random.nextInt(1 << 31);
    final expiresMs = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

    // Persist ephemeral private key so we can complete DH when acceptance arrives
    await _crypto.storeLinkEphemeralPrivateKey(linkId, keyPair);

    final payload = LinkQrPayload(
      linkId: linkId,
      initiatorNodeId: myNodeId,
      ephemeralPublicKey: Uint8List.fromList(pubKey.bytes),
      displayName: myDisplayName,
      durationMinutes: durationMinutes,
      bidirectional: bidirectional,
      nonce: nonce,
      expiresEpochMs: expiresMs,
    );

    final qrJson = jsonEncode({
      'v': 1,
      'lid': linkId,
      'nid': myNodeId,
      'pub': base64Encode(Uint8List.fromList(pubKey.bytes)),
      'dur': durationMinutes,
      'bi': bidirectional ? 1 : 0,
      'nom': nonce,
      'exp': expiresMs,
      if (myDisplayName != null) 'name': myDisplayName,
    });

    return (linkId: linkId, qrJson: qrJson, payload: payload);
  }

  // ── Responder flow ────────────────────────────────────────────────────────

  /// Called when the responder scans a QR. Performs DH, creates the link,
  /// sends acceptance DM back to the initiator.
  Future<LocationLink?> acceptFromQr(String qrJson, {String? myDisplayName}) async {
    final m = jsonDecode(qrJson) as Map<String, dynamic>;

    // Validate
    final nonce     = m['nom'] as int;
    final expiresMs = m['exp'] as int;
    if (_usedNonces.contains(nonce)) return null;     // replay attack
    if (DateTime.now().millisecondsSinceEpoch > expiresMs) return null; // expired
    _usedNonces.add(nonce);

    final linkId            = m['lid'] as String;
    final initiatorNodeId   = m['nid'] as String;
    final initiatorPubBytes = base64Decode(m['pub'] as String);
    final durationMinutes   = m['dur'] as int;
    final bidirectional     = (m['bi'] as int) == 1;
    final initiatorName     = m['name'] as String?;

    // Generate our ephemeral key pair and derive shared secret
    final myKeyPair   = await _crypto.generateEphemeralKeyPair();
    final myPubKey    = await myKeyPair.extractPublicKey();
    final myPubBytes  = Uint8List.fromList(myPubKey.bytes);
    final sharedSecret = await _crypto.deriveSharedSecret(
      myKeyPair,
      Uint8List.fromList(initiatorPubBytes),
    );

    await _crypto.storeLinkSecret(linkId, sharedSecret);

    final link = LocationLink(
      id: linkId,
      peerNodeId: initiatorNodeId,
      peerDisplayName: initiatorName,
      expiresAt: DateTime.now().add(Duration(minutes: durationMinutes)),
      bidirectional: bidirectional,
      status: LinkStatus.active,
    );

    await _saveLink(link);
    activeLinks.add(link);

    // Send acceptance DM to initiator
    final acceptance = jsonEncode({
      'type': 'link_accept',
      'lid': linkId,
      'pub': base64Encode(myPubBytes),
      if (myDisplayName != null) 'name': myDisplayName,
    });
    await Get.find<MeshMessageService>().sendDm(initiatorNodeId, acceptance);

    return link;
  }

  // ── Initiator receives acceptance ─────────────────────────────────────────

  /// Called when the initiator receives the responder's acceptance DM.
  Future<void> handleAcceptance(Map<String, dynamic> dm) async {
    final linkId          = dm['lid'] as String;
    final responderPubB64 = dm['pub'] as String;
    final responderName   = dm['name'] as String?;

    final myKeyPair = await _crypto.loadLinkEphemeralKeyPair(linkId);
    if (myKeyPair == null) return;

    final sharedSecret = await _crypto.deriveSharedSecret(
      myKeyPair,
      base64Decode(responderPubB64),
    );

    await _crypto.storeLinkSecret(linkId, sharedSecret);
    await _crypto.deleteLinkEphemeralKey(linkId); // no longer needed

    // Update the pending link to active
    final link = activeLinks.firstWhereOrNull((l) => l.id == linkId);
    if (link != null) {
      link.status = LinkStatus.active;
      link.peerDisplayName ?? responderName;
      await _saveLink(link);
      activeLinks.refresh();
    }
  }

  // ── Position exchange ─────────────────────────────────────────────────────

  /// Encrypt and send our position to all active link peers.
  Future<void> broadcastPosition(double lat, double lon) async {
    final now = DateTime.now();
    for (final link in activeLinks.where((l) => l.isActive && l.amSharing)) {
      final secret = await _crypto.loadLinkSecret(link.id);
      if (secret == null) continue;

      final payload = jsonEncode({'lat': lat, 'lon': lon, 't': now.millisecondsSinceEpoch});
      final encrypted = await _crypto.encrypt(
        secret,
        Uint8List.fromList(utf8.encode(payload)),
      );
      await Get.find<MeshMessageService>().sendDm(
        link.peerNodeId,
        jsonEncode({'type': 'link_pos', 'lid': link.id, 'd': base64Encode(encrypted)}),
      );
    }
  }

  /// Decrypt an incoming position update for a link.
  Future<void> handlePositionUpdate(Map<String, dynamic> dm) async {
    final linkId   = dm['lid'] as String;
    final dataB64  = dm['d'] as String;
    final link     = activeLinks.firstWhereOrNull((l) => l.id == linkId);
    if (link == null || !link.isActive || !link.theySharing) return;

    final secret = await _crypto.loadLinkSecret(linkId);
    if (secret == null) return;

    final plain = await _crypto.decrypt(secret, base64Decode(dataB64));
    if (plain == null) return;

    final pos = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    link.peerLat      = (pos['lat'] as num).toDouble();
    link.peerLon      = (pos['lon'] as num).toDouble();
    link.peerLastSeen = DateTime.fromMillisecondsSinceEpoch(pos['t'] as int);
    activeLinks.refresh();
  }

  // ── Revocation ────────────────────────────────────────────────────────────

  Future<void> revoke(String linkId) async {
    final link = activeLinks.firstWhereOrNull((l) => l.id == linkId);
    if (link == null) return;

    link.status = LinkStatus.revoked;
    await _saveLink(link);
    await _crypto.deleteLinkSecret(linkId);

    await Get.find<MeshMessageService>().sendDm(
      link.peerNodeId,
      jsonEncode({'type': 'link_revoke', 'lid': linkId}),
    );

    activeLinks.remove(link);
  }

  Future<void> handleRevocation(Map<String, dynamic> dm) async {
    final linkId = dm['lid'] as String;
    final link   = activeLinks.firstWhereOrNull((l) => l.id == linkId);
    if (link == null) return;

    link.status = LinkStatus.revoked;
    await _saveLink(link);
    await _crypto.deleteLinkSecret(linkId);
    activeLinks.remove(link);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _loadLinks() async {
    final rows = await _db.query(
      'location_links',
      where: 'status != ?',
      whereArgs: ['revoked'],
    );
    final loaded = rows.map(LocationLink.fromMap).toList();
    // Immediately mark any expired links
    for (final link in loaded) {
      if (!link.isActive && link.status == LinkStatus.active) {
        link.status = LinkStatus.expired;
        await _saveLink(link);
        await _crypto.deleteLinkSecret(link.id);
      }
    }
    activeLinks.assignAll(loaded.where((l) => l.isActive));
  }

  Future<void> _saveLink(LocationLink link) async {
    await _db.insert('location_links', link.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void _startExpiryTimer() {
    Stream.periodic(const Duration(minutes: 1)).listen((_) async {
      final expired = activeLinks.where((l) => !l.isActive).toList();
      for (final link in expired) {
        link.status = LinkStatus.expired;
        await _saveLink(link);
        await _crypto.deleteLinkSecret(link.id);
        activeLinks.remove(link);
      }
    });
  }
}
