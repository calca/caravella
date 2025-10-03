import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/logger_service.dart';

/// Secure storage service for managing encryption keys
/// Uses flutter_secure_storage for platform-specific secure key storage
class SecureKeyStorage {
  static final SecureKeyStorage _instance = SecureKeyStorage._internal();
  factory SecureKeyStorage() => _instance;
  SecureKeyStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _groupKeysPrefix = 'groupKey_';
  static const String _deviceKeyPrefix = 'deviceKey_';
  static const String _deviceIdKey = 'deviceId';

  /// Store a group encryption key
  Future<void> storeGroupKey(String groupId, List<int> key) async {
    try {
      final keyString = base64Encode(key);
      await _storage.write(key: '$_groupKeysPrefix$groupId', value: keyString);
      LoggerService.info('Stored group key for group: $groupId');
    } catch (e) {
      LoggerService.error('Failed to store group key for $groupId: $e');
      rethrow;
    }
  }

  /// Retrieve a group encryption key
  Future<List<int>?> getGroupKey(String groupId) async {
    try {
      final keyString = await _storage.read(key: '$_groupKeysPrefix$groupId');
      if (keyString == null) return null;
      return base64Decode(keyString);
    } catch (e) {
      LoggerService.error('Failed to retrieve group key for $groupId: $e');
      return null;
    }
  }

  /// Delete a group encryption key
  Future<void> deleteGroupKey(String groupId) async {
    try {
      await _storage.delete(key: '$_groupKeysPrefix$groupId');
      LoggerService.info('Deleted group key for group: $groupId');
    } catch (e) {
      LoggerService.error('Failed to delete group key for $groupId: $e');
    }
  }

  /// Check if a group has a stored key
  Future<bool> hasGroupKey(String groupId) async {
    final key = await getGroupKey(groupId);
    return key != null;
  }

  /// Get all group IDs that have stored keys
  Future<List<String>> getAllGroupIds() async {
    try {
      final allKeys = await _storage.readAll();
      return allKeys.keys
          .where((key) => key.startsWith(_groupKeysPrefix))
          .map((key) => key.substring(_groupKeysPrefix.length))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get all group IDs: $e');
      return [];
    }
  }

  /// Store device private key (for ECDH)
  Future<void> storeDeviceKey(List<int> privateKey) async {
    try {
      final keyString = base64Encode(privateKey);
      await _storage.write(key: _deviceKeyPrefix, value: keyString);
      LoggerService.info('Stored device private key');
    } catch (e) {
      LoggerService.error('Failed to store device key: $e');
      rethrow;
    }
  }

  /// Retrieve device private key
  Future<List<int>?> getDeviceKey() async {
    try {
      final keyString = await _storage.read(key: _deviceKeyPrefix);
      if (keyString == null) return null;
      return base64Decode(keyString);
    } catch (e) {
      LoggerService.error('Failed to retrieve device key: $e');
      return null;
    }
  }

  /// Store device ID (unique identifier for this device)
  Future<void> storeDeviceId(String deviceId) async {
    try {
      await _storage.write(key: _deviceIdKey, value: deviceId);
      LoggerService.info('Stored device ID: $deviceId');
    } catch (e) {
      LoggerService.error('Failed to store device ID: $e');
      rethrow;
    }
  }

  /// Retrieve device ID
  Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: _deviceIdKey);
    } catch (e) {
      LoggerService.error('Failed to retrieve device ID: $e');
      return null;
    }
  }

  /// Clear all stored keys (use with caution!)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      LoggerService.warning('Cleared all secure storage');
    } catch (e) {
      LoggerService.error('Failed to clear secure storage: $e');
    }
  }

  /// Clear only group keys, preserve device keys
  Future<void> clearGroupKeys() async {
    try {
      final allKeys = await _storage.readAll();
      for (final key in allKeys.keys) {
        if (key.startsWith(_groupKeysPrefix)) {
          await _storage.delete(key: key);
        }
      }
      LoggerService.info('Cleared all group keys');
    } catch (e) {
      LoggerService.error('Failed to clear group keys: $e');
    }
  }
}
