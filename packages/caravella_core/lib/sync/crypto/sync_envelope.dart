import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Encrypts/decrypts sync payloads (pairing handshakes, delta exchanges)
/// with AES-256-GCM, using a key derived once per peer via
/// [DeviceKeyManager.deriveSharedKey].
///
/// The wire format is a single base64 string: the concatenation of
/// nonce + ciphertext + MAC (via [SecretBox.concatenation]) — authenticated
/// encryption, so a tampered envelope fails to decrypt rather than silently
/// producing corrupted data.
class SyncEnvelope {
  static final AesGcm _cipher = AesGcm.with256bits();

  SyncEnvelope._();

  /// Encrypts [json] with [key], returning a base64-encoded envelope.
  static Future<String> encrypt(
    SecretKey key,
    Map<String, dynamic> json,
  ) async {
    final plainBytes = utf8.encode(jsonEncode(json));
    final secretBox = await _cipher.encrypt(plainBytes, secretKey: key);
    return base64Encode(secretBox.concatenation());
  }

  /// Decrypts a base64 [envelope] previously produced by [encrypt].
  ///
  /// Throws if the envelope is malformed or the MAC doesn't verify (wrong
  /// key or the data was tampered with in transit).
  static Future<Map<String, dynamic>> decrypt(
    SecretKey key,
    String envelope,
  ) async {
    final bytes = base64Decode(envelope);
    final secretBox = SecretBox.fromConcatenation(
      bytes,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    final plainBytes = await _cipher.decrypt(secretBox, secretKey: key);
    return jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
  }
}
