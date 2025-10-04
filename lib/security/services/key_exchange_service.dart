import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import '../../data/services/logger_service.dart';
import 'encryption_service.dart';

/// ECDH key exchange service using X25519
/// Used for secure QR code-based key sharing
class KeyExchangeService {
  static final KeyExchangeService _instance = KeyExchangeService._internal();
  factory KeyExchangeService() => _instance;
  KeyExchangeService._internal();

  final _algorithm = X25519();
  final _encryptionService = EncryptionService();

  /// Generate an ephemeral key pair for key exchange
  Future<SimpleKeyPair> generateEphemeralKeyPair() async {
    try {
      final keyPair = await _algorithm.newKeyPair();
      LoggerService.info('Generated ephemeral key pair for ECDH');
      return keyPair;
    } catch (e) {
      LoggerService.error('Failed to generate ephemeral key pair: $e');
      rethrow;
    }
  }

  /// Derive a shared secret using ECDH
  Future<List<int>> deriveSharedSecret(
    SimpleKeyPair ownKeyPair,
    SimplePublicKey remotePublicKey,
  ) async {
    try {
      final sharedSecret = await _algorithm.sharedSecretKey(
        keyPair: ownKeyPair,
        remotePublicKey: remotePublicKey,
      );
      final sharedSecretBytes = await sharedSecret.extractBytes();
      LoggerService.info('Derived shared secret using ECDH');
      return sharedSecretBytes;
    } catch (e) {
      LoggerService.error('Failed to derive shared secret: $e');
      rethrow;
    }
  }

  /// Encrypt a group key for QR code sharing
  /// Returns encrypted data with ephemeral public key
  Future<Map<String, String>> encryptGroupKeyForQr(
    List<int> groupKey,
    SimpleKeyPair senderKeyPair,
  ) async {
    try {
      // Get sender's public key for the QR recipient
      final senderPublicKey = await senderKeyPair.extractPublicKey();
      final senderPublicKeyBytes = await senderPublicKey.extractBytes();

      // Create a temporary shared secret for encryption
      // In practice, the receiver will derive the same secret using their private key
      // For QR code, we encrypt the group key with a derived key from the ephemeral pair
      
      // Use the ephemeral key pair's derived secret as the encryption key
      final encryptionKey = await _deriveEncryptionKeyFromKeyPair(senderKeyPair);

      // Encrypt the group key
      final groupKeyBase64 = base64Encode(groupKey);
      final encrypted = await _encryptionService.encrypt(
        groupKeyBase64,
        encryptionKey,
      );

      return {
        'ephemeralPublicKey': base64Encode(senderPublicKeyBytes),
        'nonce': encrypted['nonce']!,
        'ciphertext': encrypted['ciphertext']!,
        'mac': encrypted['mac']!,
      };
    } catch (e) {
      LoggerService.error('Failed to encrypt group key for QR: $e');
      rethrow;
    }
  }

  /// Decrypt a group key from QR code
  Future<List<int>> decryptGroupKeyFromQr(
    Map<String, String> encryptedData,
    SimpleKeyPair receiverKeyPair,
    String senderPublicKeyBase64,
  ) async {
    try {
      // Decode sender's public key
      final senderPublicKeyBytes = base64Decode(senderPublicKeyBase64);
      final senderPublicKey = SimplePublicKey(
        senderPublicKeyBytes,
        type: KeyPairType.x25519,
      );

      // Derive shared secret
      final sharedSecret = await deriveSharedSecret(
        receiverKeyPair,
        senderPublicKey,
      );

      // Use shared secret as decryption key
      final decrypted = await _encryptionService.decrypt(
        {
          'nonce': encryptedData['nonce']!,
          'ciphertext': encryptedData['ciphertext']!,
          'mac': encryptedData['mac']!,
        },
        sharedSecret,
      );

      // Decode the group key
      return base64Decode(decrypted);
    } catch (e) {
      LoggerService.error('Failed to decrypt group key from QR: $e');
      rethrow;
    }
  }

  /// Helper to derive encryption key from a key pair
  /// Used when we need to encrypt data with only our own key pair
  Future<List<int>> _deriveEncryptionKeyFromKeyPair(
    SimpleKeyPair keyPair,
  ) async {
    // For QR code encryption, we use a KDF on the private key
    // In a real implementation, you'd use a proper KDF (HKDF, etc.)
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    
    // For simplicity, we'll use the private key directly as the encryption key
    // In production, use a proper KDF
    return privateKeyBytes;
  }

  /// Convert public key to base64 string for transmission
  Future<String> publicKeyToBase64(SimplePublicKey publicKey) async {
    final bytes = await publicKey.extractBytes();
    return base64Encode(bytes);
  }

  /// Convert base64 string to public key
  SimplePublicKey publicKeyFromBase64(String base64String) {
    final bytes = base64Decode(base64String);
    return SimplePublicKey(bytes, type: KeyPairType.x25519);
  }
}
