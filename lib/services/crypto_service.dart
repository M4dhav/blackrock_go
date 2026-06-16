import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles all cryptographic operations for Blackrock-GO.
///
/// Key hierarchy:
///   Node identity key (X25519, persists for the event) — used for DMs
///   Camp group key (AES-256, per camp) — encrypts message content
///   Camp location key (AES-256, per camp) — encrypts position packets
///   Link shared secrets (X25519 derived, per playa link) — ephemeral
///
/// Sensitive key material lives exclusively in flutter_secure_storage
/// (iOS Keychain / Android Keystore). Never in SQLite or SharedPreferences.
class CryptoService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kNodePrivate = 'brg_node_private_key';
  static const _kNodePublic  = 'brg_node_public_key';

  final _x25519 = X25519();
  final _aesGcm = AesGcm.with256bits();
  final _random = Random.secure();

  SimpleKeyPair? _nodeKeyPair;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Load or generate the persistent node identity key pair.
  /// Call once at app start before any other crypto operations.
  Future<void> initialize() async {
    final stored = await _storage.read(key: _kNodePrivate);
    if (stored != null) {
      final seed = base64Decode(stored);
      _nodeKeyPair = await _x25519.newKeyPairFromSeed(seed);
    } else {
      _nodeKeyPair = await _x25519.newKeyPair();
      final seed = await _nodeKeyPair!.extractPrivateKeyBytes();
      final pub  = await _nodeKeyPair!.extractPublicKey();
      await _storage.write(key: _kNodePrivate, value: base64Encode(seed));
      await _storage.write(key: _kNodePublic,  value: base64Encode(pub.bytes));
    }
  }

  /// Returns this device's X25519 public key bytes (shareable, goes in QR).
  Future<Uint8List> getNodePublicKey() async {
    final pub = await _nodeKeyPair!.extractPublicKey();
    return Uint8List.fromList(pub.bytes);
  }

  // ── Key generation ────────────────────────────────────────────────────────

  /// Fresh ephemeral X25519 key pair — used for playa links.
  /// Caller is responsible for storing the private key in secure storage
  /// and discarding it when the link expires.
  Future<SimpleKeyPair> generateEphemeralKeyPair() => _x25519.newKeyPair();

  /// 32-byte random symmetric key — used for camp group key / location key.
  Future<Uint8List> generateSymmetricKey() async {
    final key = await _aesGcm.newSecretKey();
    return Uint8List.fromList(await key.extractBytes());
  }

  // ── Diffie-Hellman ────────────────────────────────────────────────────────

  /// Derive a shared secret from our private key + their raw public key bytes.
  /// Used for playa link establishment (stranger-to-stranger QR flow).
  Future<Uint8List> deriveSharedSecret(
    SimpleKeyPair myKeyPair,
    Uint8List theirPublicKeyBytes,
  ) async {
    final theirPub = SimplePublicKey(
      theirPublicKeyBytes.toList(),
      type: KeyPairType.x25519,
    );
    final secret = await _x25519.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: theirPub,
    );
    return Uint8List.fromList(await secret.extractBytes());
  }

  /// Derive shared secret using the persistent node identity key.
  /// Used for encrypting camp group key delivery via DM.
  Future<Uint8List> deriveSharedSecretWithNodeKey(
    Uint8List theirPublicKeyBytes,
  ) async {
    return deriveSharedSecret(_nodeKeyPair!, theirPublicKeyBytes);
  }

  // ── Symmetric encryption (AES-256-GCM) ───────────────────────────────────

  /// Encrypt [plaintext] with [keyBytes] (32 bytes).
  /// Returns: [12-byte nonce][ciphertext][16-byte MAC tag]
  Future<Uint8List> encrypt(Uint8List keyBytes, Uint8List plaintext) async {
    final nonce     = _randomNonce();
    final secretKey = SecretKey(keyBytes.toList());
    final box       = await _aesGcm.encrypt(
      plaintext.toList(),
      secretKey: secretKey,
      nonce: nonce,
    );
    return Uint8List.fromList([...box.nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  /// Decrypt payload produced by [encrypt]. Returns null if authentication fails.
  Future<Uint8List?> decrypt(Uint8List keyBytes, Uint8List payload) async {
    if (payload.length < 28) return null; // 12 nonce + 0 ct + 16 mac minimum
    try {
      final nonce      = payload.sublist(0, 12).toList();
      final macBytes   = payload.sublist(payload.length - 16).toList();
      final cipherText = payload.sublist(12, payload.length - 16).toList();
      final secretKey  = SecretKey(keyBytes.toList());
      final box        = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
      final plain      = await _aesGcm.decrypt(box, secretKey: secretKey);
      return Uint8List.fromList(plain);
    } catch (_) {
      return null;
    }
  }

  // ── Secure storage helpers ────────────────────────────────────────────────

  Future<void> storeCampGroupKey(String campId, Uint8List key) =>
      _storage.write(key: 'camp_${campId}_group', value: base64Encode(key));

  Future<void> storeCampLocationKey(String campId, Uint8List key) =>
      _storage.write(key: 'camp_${campId}_location', value: base64Encode(key));

  Future<Uint8List?> loadCampGroupKey(String campId) async {
    final v = await _storage.read(key: 'camp_${campId}_group');
    return v != null ? base64Decode(v) : null;
  }

  Future<Uint8List?> loadCampLocationKey(String campId) async {
    final v = await _storage.read(key: 'camp_${campId}_location');
    return v != null ? base64Decode(v) : null;
  }

  Future<void> storeLinkSecret(String linkId, Uint8List secret) =>
      _storage.write(key: 'link_${linkId}_secret', value: base64Encode(secret));

  Future<Uint8List?> loadLinkSecret(String linkId) async {
    final v = await _storage.read(key: 'link_${linkId}_secret');
    return v != null ? base64Decode(v) : null;
  }

  Future<void> deleteLinkSecret(String linkId) =>
      _storage.delete(key: 'link_${linkId}_secret');

  Future<void> storeLinkEphemeralPrivateKey(String linkId, SimpleKeyPair kp) async {
    final seed = await kp.extractPrivateKeyBytes();
    await _storage.write(key: 'link_${linkId}_ephemeral', value: base64Encode(seed));
  }

  Future<SimpleKeyPair?> loadLinkEphemeralKeyPair(String linkId) async {
    final v = await _storage.read(key: 'link_${linkId}_ephemeral');
    if (v == null) return null;
    return _x25519.newKeyPairFromSeed(base64Decode(v));
  }

  Future<void> deleteLinkEphemeralKey(String linkId) =>
      _storage.delete(key: 'link_${linkId}_ephemeral');

  Future<void> deleteCampKeys(String campId) async {
    await _storage.delete(key: 'camp_${campId}_group');
    await _storage.delete(key: 'camp_${campId}_location');
  }

  // ── End-of-event cleanup ──────────────────────────────────────────────────

  /// Wipe all stored key material. Call at end of event.
  Future<void> clearAll() async {
    await _storage.deleteAll();
    _nodeKeyPair = null;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  List<int> _randomNonce() => List.generate(12, (_) => _random.nextInt(256));
}
