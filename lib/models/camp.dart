import 'dart:convert';
import 'dart:typed_data';

enum CampRole { lead, member }

class Camp {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final int meshtasticSlot;
  final Uint8List channelPsk;   // Meshtastic transport PSK (in QR, not secret)
  final String? gatewayNodeId; // camp's Pi gateway Meshtastic node ID
  final CampRole role;
  final DateTime joinedAt;
  List<CampMember> members;

  Camp({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    required this.meshtasticSlot,
    required this.channelPsk,
    this.gatewayNodeId,
    required this.role,
    required this.joinedAt,
    this.members = const [],
  });

  /// Encode for QR code — contains only transport-layer info.
  /// App-layer group key and location key are NEVER in the QR.
  String toQrPayload() {
    return jsonEncode({
      'v': 1,
      'id': id,
      'name': name,
      'slot': meshtasticSlot,
      'psk': base64Encode(channelPsk),
      if (gatewayNodeId != null) 'node': gatewayNodeId,
      if (latitude != null) 'lat': latitude,
      if (longitude != null) 'lon': longitude,
    });
  }

  static Camp fromQrPayload(String payload) {
    final m = jsonDecode(payload) as Map<String, dynamic>;
    return Camp(
      id: m['id'] as String,
      name: m['name'] as String,
      meshtasticSlot: m['slot'] as int,
      channelPsk: base64Decode(m['psk'] as String),
      gatewayNodeId: m['node'] as String?,
      latitude: (m['lat'] as num?)?.toDouble(),
      longitude: (m['lon'] as num?)?.toDouble(),
      role: CampRole.member,
      joinedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'meshtastic_slot': meshtasticSlot,
    'channel_psk': base64Encode(channelPsk),
    'gateway_node_id': gatewayNodeId,
    'role': role.name,
    'joined_at': joinedAt.millisecondsSinceEpoch,
  };

  static Camp fromMap(Map<String, dynamic> m) => Camp(
    id: m['id'] as String,
    name: m['name'] as String,
    latitude: m['latitude'] as double?,
    longitude: m['longitude'] as double?,
    meshtasticSlot: m['meshtastic_slot'] as int,
    channelPsk: base64Decode(m['channel_psk'] as String),
    gatewayNodeId: m['gateway_node_id'] as String?,
    role: CampRole.values.byName(m['role'] as String),
    joinedAt: DateTime.fromMillisecondsSinceEpoch(m['joined_at'] as int),
  );
}

class CampMember {
  final String id;
  final String campId;
  final String nodeId;            // Meshtastic node ID e.g. !a3f92c1b
  final String? displayName;
  final Uint8List? publicKey;     // X25519 public key — for DM key delivery
  final CampRole role;
  bool locationOptIn;
  DateTime? lastSeen;
  double? lastLat;
  double? lastLon;

  CampMember({
    required this.id,
    required this.campId,
    required this.nodeId,
    this.displayName,
    this.publicKey,
    required this.role,
    this.locationOptIn = false,
    this.lastSeen,
    this.lastLat,
    this.lastLon,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'camp_id': campId,
    'node_id': nodeId,
    'display_name': displayName,
    'public_key': publicKey != null ? base64Encode(publicKey!) : null,
    'role': role.name,
    'location_opt_in': locationOptIn ? 1 : 0,
    'last_seen': lastSeen?.millisecondsSinceEpoch,
    'last_lat': lastLat,
    'last_lon': lastLon,
  };

  static CampMember fromMap(Map<String, dynamic> m) => CampMember(
    id: m['id'] as String,
    campId: m['camp_id'] as String,
    nodeId: m['node_id'] as String,
    displayName: m['display_name'] as String?,
    publicKey: m['public_key'] != null ? base64Decode(m['public_key'] as String) : null,
    role: CampRole.values.byName(m['role'] as String),
    locationOptIn: (m['location_opt_in'] as int) == 1,
    lastSeen: m['last_seen'] != null
        ? DateTime.fromMillisecondsSinceEpoch(m['last_seen'] as int)
        : null,
    lastLat: m['last_lat'] as double?,
    lastLon: m['last_lon'] as double?,
  );
}
