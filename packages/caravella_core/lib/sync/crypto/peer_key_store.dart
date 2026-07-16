import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists each paired peer's derived symmetric sync key (see
/// [DeviceKeyManager.deriveSharedKey]) in the platform Keystore/Keychain,
/// keyed by device ID.
class PeerKeyStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  PeerKeyStore._();

  static String _storageKey(String deviceId) => 'sync_peer_key_$deviceId';

  /// Persists the derived shared key for [deviceId].
  static Future<void> save(String deviceId, SecretKey key) async {
    final bytes = await key.extractBytes();
    await _storage.write(
      key: _storageKey(deviceId),
      value: base64Encode(bytes),
    );
  }

  /// Returns the persisted shared key for [deviceId], or `null` if this
  /// device has never paired with it (or the key was cleared).
  static Future<SecretKey?> get(String deviceId) async {
    final stored = await _storage.read(key: _storageKey(deviceId));
    if (stored == null) return null;
    return SecretKey(base64Decode(stored));
  }

  /// Removes the persisted shared key for [deviceId] — call when revoking a
  /// device's last group grant.
  static Future<void> remove(String deviceId) async {
    await _storage.delete(key: _storageKey(deviceId));
  }
}
