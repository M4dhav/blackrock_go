import 'dart:typed_data';

enum LinkStatus { pending, active, expired, revoked }

/// Ephemeral location-sharing link between two strangers.
/// Established via QR code + X25519 key exchange.
/// Keys live in flutter_secure_storage; only metadata is in SQLite.
class LocationLink {
  final String id;
  final String peerNodeId;
  final String? peerDisplayName;
  final DateTime expiresAt;
  final bool bidirectional;
  LinkStatus status;
  bool amSharing;     // I am sharing my location with them
  bool theySharing;   // They are sharing their location with me
  double? peerLat;
  double? peerLon;
  DateTime? peerLastSeen;

  LocationLink({
    required this.id,
    required this.peerNodeId,
    this.peerDisplayName,
    required this.expiresAt,
    required this.bidirectional,
    this.status = LinkStatus.pending,
    this.amSharing = true,
    this.theySharing = true,
    this.peerLat,
    this.peerLon,
    this.peerLastSeen,
  });

  bool get isActive =>
      status == LinkStatus.active && DateTime.now().isBefore(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toMap() => {
    'id': id,
    'peer_node_id': peerNodeId,
    'peer_display_name': peerDisplayName,
    'expires_at': expiresAt.millisecondsSinceEpoch,
    'bidirectional': bidirectional ? 1 : 0,
    'status': status.name,
    'am_sharing': amSharing ? 1 : 0,
    'they_sharing': theySharing ? 1 : 0,
  };

  static LocationLink fromMap(Map<String, dynamic> m) => LocationLink(
    id: m['id'] as String,
    peerNodeId: m['peer_node_id'] as String,
    peerDisplayName: m['peer_display_name'] as String?,
    expiresAt: DateTime.fromMillisecondsSinceEpoch(m['expires_at'] as int),
    bidirectional: (m['bidirectional'] as int) == 1,
    status: LinkStatus.values.byName(m['status'] as String),
    amSharing: (m['am_sharing'] as int) == 1,
    theySharing: (m['they_sharing'] as int) == 1,
  );
}

/// QR payload for initiating a playa link.
/// Contains initiator's ephemeral public key — single-use nonce prevents replay.
class LinkQrPayload {
  final String linkId;
  final String initiatorNodeId;
  final Uint8List ephemeralPublicKey;
  final String? displayName;
  final int durationMinutes;
  final bool bidirectional;
  final int nonce;            // single-use, validated by responder
  final int expiresEpochMs;  // QR valid for 5 minutes

  LinkQrPayload({
    required this.linkId,
    required this.initiatorNodeId,
    required this.ephemeralPublicKey,
    this.displayName,
    required this.durationMinutes,
    required this.bidirectional,
    required this.nonce,
    required this.expiresEpochMs,
  });

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch > expiresEpochMs;
}
