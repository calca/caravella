import 'package:uuid/uuid.dart';
import '../../data/services/logger_service.dart';
import '../models/qr_key_exchange_payload.dart';
import '../../security/services/secure_key_storage.dart';
import '../../security/services/key_exchange_service.dart';
import '../../security/services/encryption_service.dart';

/// Service for generating QR codes for group key sharing
class QrGenerationService {
  static final QrGenerationService _instance = QrGenerationService._internal();
  factory QrGenerationService() => _instance;
  QrGenerationService._internal();

  final _keyStorage = SecureKeyStorage();
  final _keyExchange = KeyExchangeService();

  /// Generate a QR code payload for sharing a group key
  /// Returns the payload that should be encoded in the QR code
  Future<QrKeyExchangePayload?> generateQrPayload(
    String groupId, {
    int expirationSeconds = 300,
  }) async {
    try {
      LoggerService.info('Generating QR payload for group: $groupId');

      // 1. Get the group key from secure storage
      final groupKey = await _keyStorage.getGroupKey(groupId);
      if (groupKey == null) {
        LoggerService.error('No group key found for group: $groupId');
        return null;
      }

      // 2. Generate ephemeral key pair for this QR code
      final ephemeralKeyPair = await _keyExchange.generateEphemeralKeyPair();

      // 3. Encrypt the group key using the ephemeral key pair
      final encryptedData = await _keyExchange.encryptGroupKeyForQr(
        groupKey,
        ephemeralKeyPair,
      );

      // 4. Create the QR payload
      final payload = QrKeyExchangePayload(
        groupId: groupId,
        ephemeralPublicKey: encryptedData['ephemeralPublicKey']!,
        nonce: encryptedData['nonce']!,
        encryptedGroupKey: encryptedData['ciphertext']!,
        mac: encryptedData['mac']!,
        expirationSeconds: expirationSeconds,
      );

      LoggerService.info('Generated QR payload for group: $groupId');
      return payload;
    } catch (e) {
      LoggerService.error('Failed to generate QR payload: $e');
      return null;
    }
  }

  /// Validate and process a scanned QR code payload
  /// Returns the group ID and stores the decrypted group key
  Future<String?> processScannedQr(
    QrKeyExchangePayload payload,
  ) async {
    try {
      LoggerService.info('Processing scanned QR for group: ${payload.groupId}');

      // 1. Check if QR code has expired
      if (payload.isExpired) {
        LoggerService.warning('QR code expired for group: ${payload.groupId}');
        return null;
      }

      // 2. Check if we already have a key for this group
      final existingKey = await _keyStorage.hasGroupKey(payload.groupId);
      if (existingKey) {
        LoggerService.info('Group key already exists for: ${payload.groupId}');
        return payload.groupId;
      }

      // 3. Generate a key pair for this device if not exists
      final deviceKey = await _keyStorage.getDeviceKey();
      final deviceKeyPair = deviceKey != null
          ? await _keyExchange.generateEphemeralKeyPair() // TODO: Load from storage
          : await _keyExchange.generateEphemeralKeyPair();

      // 4. Decrypt the group key using ECDH
      final groupKey = await _keyExchange.decryptGroupKeyFromQr(
        {
          'nonce': payload.nonce,
          'ciphertext': payload.encryptedGroupKey,
          'mac': payload.mac,
        },
        deviceKeyPair,
        payload.ephemeralPublicKey,
      );

      // 5. Store the decrypted group key
      await _keyStorage.storeGroupKey(payload.groupId, groupKey);

      // 6. Generate and store device ID if not exists
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) {
        final newDeviceId = const Uuid().v4();
        await _keyStorage.storeDeviceId(newDeviceId);
      }

      LoggerService.info('Successfully processed QR for group: ${payload.groupId}');
      return payload.groupId;
    } catch (e) {
      LoggerService.error('Failed to process scanned QR: $e');
      return null;
    }
  }

  /// Check if a group has a stored encryption key
  Future<bool> hasGroupKey(String groupId) async {
    return await _keyStorage.hasGroupKey(groupId);
  }

  /// Initialize encryption for a new group
  /// Generates and stores a new group key
  Future<bool> initializeGroupEncryption(String groupId) async {
    try {
      LoggerService.info('Initializing encryption for group: $groupId');

      // Check if key already exists
      final existingKey = await _keyStorage.hasGroupKey(groupId);
      if (existingKey) {
        LoggerService.info('Group key already exists for: $groupId');
        return true;
      }

      // Generate new group key
      final encryptionService = EncryptionService();
      final groupKey = await encryptionService.generateKey();

      // Store the group key
      await _keyStorage.storeGroupKey(groupId, groupKey);

      // Generate and store device ID if not exists
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) {
        final newDeviceId = const Uuid().v4();
        await _keyStorage.storeDeviceId(newDeviceId);
      }

      LoggerService.info('Initialized encryption for group: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to initialize group encryption: $e');
      return false;
    }
  }

  /// Remove encryption key for a group (when deleting a group)
  Future<void> removeGroupKey(String groupId) async {
    await _keyStorage.deleteGroupKey(groupId);
    LoggerService.info('Removed encryption key for group: $groupId');
  }
}
