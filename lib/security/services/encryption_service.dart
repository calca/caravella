import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import '../../data/services/logger_service.dart';

/// AES-256-GCM encryption service for group data
/// Provides authenticated encryption with associated data (AEAD)
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _algorithm = AesGcm.with256bits();

  /// Generate a new random 256-bit encryption key
  Future<List<int>> generateKey() async {
    try {
      final secretKey = await _algorithm.newSecretKey();
      final keyBytes = await secretKey.extractBytes();
      LoggerService.info('Generated new AES-256 encryption key');
      return keyBytes;
    } catch (e) {
      LoggerService.error('Failed to generate encryption key: $e');
      rethrow;
    }
  }

  /// Encrypt data with AES-256-GCM
  /// Returns a map with 'nonce' and 'ciphertext' (both base64 encoded)
  Future<Map<String, String>> encrypt(
    String plaintext,
    List<int> keyBytes,
  ) async {
    try {
      final secretKey = SecretKey(keyBytes);
      final nonce = _algorithm.newNonce();

      final secretBox = await _algorithm.encrypt(
        utf8.encode(plaintext),
        secretKey: secretKey,
        nonce: nonce,
      );

      return {
        'nonce': base64Encode(nonce),
        'ciphertext': base64Encode(secretBox.cipherText),
        'mac': base64Encode(secretBox.mac.bytes),
      };
    } catch (e) {
      LoggerService.error('Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt data with AES-256-GCM
  /// Expects a map with 'nonce', 'ciphertext', and 'mac' (all base64 encoded)
  Future<String> decrypt(
    Map<String, String> encryptedData,
    List<int> keyBytes,
  ) async {
    try {
      final secretKey = SecretKey(keyBytes);
      final nonce = base64Decode(encryptedData['nonce']!);
      final ciphertext = base64Decode(encryptedData['ciphertext']!);
      final mac = Mac(base64Decode(encryptedData['mac']!));

      final secretBox = SecretBox(
        ciphertext,
        nonce: nonce,
        mac: mac,
      );

      final plaintext = await _algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return utf8.decode(plaintext);
    } catch (e) {
      LoggerService.error('Decryption failed: $e');
      rethrow;
    }
  }

  /// Encrypt JSON object
  Future<Map<String, String>> encryptJson(
    Map<String, dynamic> data,
    List<int> keyBytes,
  ) async {
    final jsonString = jsonEncode(data);
    return await encrypt(jsonString, keyBytes);
  }

  /// Decrypt to JSON object
  Future<Map<String, dynamic>> decryptJson(
    Map<String, String> encryptedData,
    List<int> keyBytes,
  ) async {
    final jsonString = await decrypt(encryptedData, keyBytes);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Encrypt binary data (for files, images, etc.)
  Future<Map<String, dynamic>> encryptBytes(
    Uint8List data,
    List<int> keyBytes,
  ) async {
    try {
      final secretKey = SecretKey(keyBytes);
      final nonce = _algorithm.newNonce();

      final secretBox = await _algorithm.encrypt(
        data,
        secretKey: secretKey,
        nonce: nonce,
      );

      return {
        'nonce': nonce,
        'ciphertext': secretBox.cipherText,
        'mac': secretBox.mac.bytes,
      };
    } catch (e) {
      LoggerService.error('Binary encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt binary data
  Future<Uint8List> decryptBytes(
    Map<String, dynamic> encryptedData,
    List<int> keyBytes,
  ) async {
    try {
      final secretKey = SecretKey(keyBytes);
      final nonce = encryptedData['nonce'] as List<int>;
      final ciphertext = encryptedData['ciphertext'] as List<int>;
      final mac = Mac(encryptedData['mac'] as List<int>);

      final secretBox = SecretBox(
        ciphertext,
        nonce: nonce,
        mac: mac,
      );

      final plaintext = await _algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return Uint8List.fromList(plaintext);
    } catch (e) {
      LoggerService.error('Binary decryption failed: $e');
      rethrow;
    }
  }
}
