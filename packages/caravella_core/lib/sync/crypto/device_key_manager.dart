import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:caravella_core/services/logging/logger_service.dart';

/// Manages this device's long-term X25519 identity keypair, used to bootstrap
/// end-to-end encryption for LAN/Bluetooth sync pairing.
///
/// The private key never leaves this device — only the public key is ever
/// transmitted (embedded in a pairing QR code or a Bluetooth handshake), so a
/// device that only observes the QR code (e.g. a photo taken by a bystander)
/// cannot derive the shared key without the other side's private key.
class DeviceKeyManager {
  static const _tag = 'sync.crypto.device_key';
  static const _privateKeySeedStorageKey = 'sync_device_private_key_seed';
  static const _hkdfInfo = 'caravella-sync-v1';

  static final X25519 _algorithm = X25519();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static SimpleKeyPair? _keyPair;

  DeviceKeyManager._();

  /// Loads (or generates, on first use) this device's X25519 keypair.
  static Future<SimpleKeyPair> _keyPairInstance() async {
    final cached = _keyPair;
    if (cached != null) return cached;

    final existingSeed = await _storage.read(key: _privateKeySeedStorageKey);
    if (existingSeed != null) {
      final keyPair = await _algorithm.newKeyPairFromSeed(
        base64Decode(existingSeed),
      );
      _keyPair = keyPair;
      LoggerService.debug('Loaded existing device key pair', name: _tag);
      return keyPair;
    }

    final keyPair = await _algorithm.newKeyPair();
    final seed = await keyPair.extractPrivateKeyBytes();
    await _storage.write(
      key: _privateKeySeedStorageKey,
      value: base64Encode(seed),
    );
    _keyPair = keyPair;
    LoggerService.info('Generated new device key pair', name: _tag);
    return keyPair;
  }

  /// This device's public key, base64-encoded — safe to share (embedded in
  /// pairing QR codes / Bluetooth handshakes).
  static Future<String> publicKeyBase64() async {
    final keyPair = await _keyPairInstance();
    final publicKey = await keyPair.extractPublicKey();
    return base64Encode(publicKey.bytes);
  }

  /// Derives the shared symmetric key for a peer given their public key
  /// (base64-encoded, as received via QR/Bluetooth), via X25519 ECDH
  /// followed by HKDF-SHA256 expansion to a 256-bit AES key.
  ///
  /// Both sides of a pairing call this with the other's public key and
  /// arrive at the identical [SecretKey] — the ECDH shared secret is never
  /// transmitted.
  static Future<SecretKey> deriveSharedKey(String peerPublicKeyBase64) async {
    final keyPair = await _keyPairInstance();
    final remotePublicKey = SimplePublicKey(
      base64Decode(peerPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _algorithm.sharedSecretKey(
      keyPair: keyPair,
      remotePublicKey: remotePublicKey,
    );

    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    return hkdf.deriveKey(
      secretKey: sharedSecret,
      info: utf8.encode(_hkdfInfo),
    );
  }

  /// Resets the cached keypair. Intended for testing only.
  static void resetForTesting() => _keyPair = null;
}
