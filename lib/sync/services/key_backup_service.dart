import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import '../../data/services/logger_service.dart';
import '../../security/services/secure_key_storage.dart';
import '../../security/services/encryption_service.dart';

/// Service for backing up and recovering encryption keys
class KeyBackupService {
  static final KeyBackupService _instance = KeyBackupService._internal();
  factory KeyBackupService() => _instance;
  KeyBackupService._internal();

  final _keyStorage = SecureKeyStorage();
  final _encryption = EncryptionService();

  /// Create a backup of all group keys
  /// The backup is encrypted with a user-provided password
  Future<String?> createBackup(String password) async {
    try {
      LoggerService.info('Creating key backup...');

      // 1. Get all group IDs that have keys
      final groupIds = await _keyStorage.getAllGroupIds();
      if (groupIds.isEmpty) {
        LoggerService.warning('No groups to backup');
        return null;
      }

      // 2. Collect all group keys
      final Map<String, String> keyMap = {};
      for (final groupId in groupIds) {
        final key = await _keyStorage.getGroupKey(groupId);
        if (key != null) {
          keyMap[groupId] = base64Encode(key);
        }
      }

      // 3. Get device ID
      final deviceId = await _keyStorage.getDeviceId();

      // 4. Create backup structure
      final backup = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'deviceId': deviceId,
        'groups': keyMap,
      };

      // 5. Encrypt backup with password
      final backupJson = jsonEncode(backup);
      final encryptedBackup = await _encryptWithPassword(
        backupJson,
        password,
      );

      LoggerService.info('Key backup created successfully');
      return encryptedBackup;
    } catch (e) {
      LoggerService.error('Failed to create backup: $e');
      return null;
    }
  }

  /// Restore keys from a backup
  /// Requires the password used to create the backup
  Future<bool> restoreFromBackup(String backupData, String password) async {
    try {
      LoggerService.info('Restoring from backup...');

      // 1. Decrypt backup with password
      final decryptedJson = await _decryptWithPassword(
        backupData,
        password,
      );

      if (decryptedJson == null) {
        LoggerService.error('Failed to decrypt backup - wrong password?');
        return false;
      }

      // 2. Parse backup structure
      final backup = jsonDecode(decryptedJson) as Map<String, dynamic>;
      final version = backup['version'] as int;
      
      if (version != 1) {
        LoggerService.error('Unsupported backup version: $version');
        return false;
      }

      // 3. Restore all group keys
      final groups = backup['groups'] as Map<String, dynamic>;
      int restored = 0;
      
      for (final entry in groups.entries) {
        final groupId = entry.key;
        final keyBase64 = entry.value as String;
        final key = base64Decode(keyBase64);
        
        await _keyStorage.storeGroupKey(groupId, key);
        restored++;
      }

      LoggerService.info('Restored $restored group keys from backup');
      return true;
    } catch (e) {
      LoggerService.error('Failed to restore backup: $e');
      return false;
    }
  }

  /// Encrypt data with a password using PBKDF2 + AES
  Future<String> _encryptWithPassword(String plaintext, String password) async {
    try {
      // Use PBKDF2 to derive a key from the password
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 100000,
        bits: 256,
      );

      // Generate a random salt
      final salt = List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch % 256);
      
      // Derive key from password
      final secretKey = await pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(password)),
        nonce: salt,
      );

      final keyBytes = await secretKey.extractBytes();

      // Encrypt with AES
      final encrypted = await _encryption.encrypt(plaintext, keyBytes);

      // Combine salt and encrypted data
      final result = {
        'salt': base64Encode(salt),
        'nonce': encrypted['nonce']!,
        'ciphertext': encrypted['ciphertext']!,
        'mac': encrypted['mac']!,
      };

      return base64Encode(utf8.encode(jsonEncode(result)));
    } catch (e) {
      LoggerService.error('Failed to encrypt with password: $e');
      rethrow;
    }
  }

  /// Decrypt data with a password
  Future<String?> _decryptWithPassword(String encryptedData, String password) async {
    try {
      // Decode the encrypted data
      final decoded = jsonDecode(
        utf8.decode(base64Decode(encryptedData)),
      ) as Map<String, dynamic>;

      final salt = base64Decode(decoded['salt'] as String);
      
      // Derive key from password using same parameters
      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 100000,
        bits: 256,
      );

      final secretKey = await pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(password)),
        nonce: salt,
      );

      final keyBytes = await secretKey.extractBytes();

      // Decrypt with AES
      final decrypted = await _encryption.decrypt(
        {
          'nonce': decoded['nonce'] as String,
          'ciphertext': decoded['ciphertext'] as String,
          'mac': decoded['mac'] as String,
        },
        keyBytes,
      );

      return decrypted;
    } catch (e) {
      LoggerService.error('Failed to decrypt with password: $e');
      return null;
    }
  }

  /// Export a single group key (for advanced users)
  Future<String?> exportGroupKey(String groupId, String password) async {
    try {
      final key = await _keyStorage.getGroupKey(groupId);
      if (key == null) return null;

      final export = {
        'groupId': groupId,
        'key': base64Encode(key),
        'timestamp': DateTime.now().toIso8601String(),
      };

      return await _encryptWithPassword(jsonEncode(export), password);
    } catch (e) {
      LoggerService.error('Failed to export group key: $e');
      return null;
    }
  }

  /// Import a single group key
  Future<bool> importGroupKey(String exportData, String password) async {
    try {
      final decrypted = await _decryptWithPassword(exportData, password);
      if (decrypted == null) return false;

      final export = jsonDecode(decrypted) as Map<String, dynamic>;
      final groupId = export['groupId'] as String;
      final keyBase64 = export['key'] as String;
      final key = base64Decode(keyBase64);

      await _keyStorage.storeGroupKey(groupId, key);
      LoggerService.info('Imported group key for: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to import group key: $e');
      return false;
    }
  }

  /// Validate a backup without restoring it
  Future<Map<String, dynamic>?> validateBackup(
    String backupData,
    String password,
  ) async {
    try {
      final decryptedJson = await _decryptWithPassword(backupData, password);
      if (decryptedJson == null) return null;

      final backup = jsonDecode(decryptedJson) as Map<String, dynamic>;
      final groups = backup['groups'] as Map<String, dynamic>;

      return {
        'version': backup['version'],
        'timestamp': backup['timestamp'],
        'deviceId': backup['deviceId'],
        'groupCount': groups.length,
        'groupIds': groups.keys.toList(),
      };
    } catch (e) {
      LoggerService.error('Failed to validate backup: $e');
      return null;
    }
  }
}
