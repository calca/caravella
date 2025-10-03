import 'dart:convert';
import '../../data/services/logger_service.dart';
import '../../security/services/secure_key_storage.dart';
import '../models/device_info.dart';
import '../models/sync_event.dart';
import 'realtime_sync_service.dart';

/// Manages devices that have access to groups
class DeviceManagementService {
  static final DeviceManagementService _instance =
      DeviceManagementService._internal();
  factory DeviceManagementService() => _instance;
  DeviceManagementService._internal();

  final _keyStorage = SecureKeyStorage();
  final _realtimeSync = RealtimeSyncService();

  // In-memory cache of device lists per group
  final Map<String, List<DeviceInfo>> _deviceCache = {};

  /// Get list of devices for a group
  Future<List<DeviceInfo>> getDevicesForGroup(String groupId) async {
    try {
      // Check cache first
      if (_deviceCache.containsKey(groupId)) {
        return _deviceCache[groupId]!;
      }

      // In a real implementation, this would fetch from Supabase or storage
      // For now, return current device only
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) {
        return [];
      }

      final currentDevice = await DeviceInfo.createForCurrentDevice(deviceId);
      final devices = [currentDevice];

      _deviceCache[groupId] = devices;
      return devices;
    } catch (e) {
      LoggerService.error('Failed to get devices for group: $e');
      return [];
    }
  }

  /// Register current device for a group
  Future<bool> registerDevice(String groupId) async {
    try {
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) {
        LoggerService.error('No device ID available');
        return false;
      }

      final device = await DeviceInfo.createForCurrentDevice(deviceId);

      // Broadcast device registration event
      final event = SyncEvent(
        type: SyncEventType.groupMetadataUpdated,
        groupId: groupId,
        deviceId: deviceId,
        encryptedPayload: jsonEncode({
          'action': 'device_registered',
          'device': device.toJson(),
        }),
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      await _realtimeSync.broadcastSyncEvent(event);

      // Update cache
      final devices = await getDevicesForGroup(groupId);
      devices.add(device);
      _deviceCache[groupId] = devices;

      LoggerService.info('Device registered for group: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to register device: $e');
      return false;
    }
  }

  /// Revoke device access to a group
  Future<bool> revokeDevice(String groupId, String deviceId) async {
    try {
      final currentDeviceId = await _keyStorage.getDeviceId();
      if (currentDeviceId == null) {
        return false;
      }

      // Can't revoke current device
      if (deviceId == currentDeviceId) {
        LoggerService.warning('Cannot revoke current device');
        return false;
      }

      // Broadcast device revocation event
      final event = SyncEvent(
        type: SyncEventType.groupMetadataUpdated,
        groupId: groupId,
        deviceId: currentDeviceId,
        encryptedPayload: jsonEncode({
          'action': 'device_revoked',
          'revokedDeviceId': deviceId,
        }),
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      await _realtimeSync.broadcastSyncEvent(event);

      // Update cache
      if (_deviceCache.containsKey(groupId)) {
        _deviceCache[groupId]!.removeWhere((d) => d.deviceId == deviceId);
      }

      LoggerService.info('Device revoked for group: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to revoke device: $e');
      return false;
    }
  }

  /// Update device last active timestamp
  Future<void> updateDeviceActivity(String groupId) async {
    try {
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) return;

      if (_deviceCache.containsKey(groupId)) {
        final devices = _deviceCache[groupId]!;
        final index = devices.indexWhere((d) => d.deviceId == deviceId);
        if (index != -1) {
          devices[index] = devices[index].copyWith(
            lastActiveAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Failed to update device activity: $e');
    }
  }

  /// Rename a device
  Future<bool> renameDevice(String groupId, String deviceId, String newName) async {
    try {
      final currentDeviceId = await _keyStorage.getDeviceId();
      if (currentDeviceId == null) return false;

      // Broadcast device rename event
      final event = SyncEvent(
        type: SyncEventType.groupMetadataUpdated,
        groupId: groupId,
        deviceId: currentDeviceId,
        encryptedPayload: jsonEncode({
          'action': 'device_renamed',
          'targetDeviceId': deviceId,
          'newName': newName,
        }),
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      await _realtimeSync.broadcastSyncEvent(event);

      // Update cache
      if (_deviceCache.containsKey(groupId)) {
        final devices = _deviceCache[groupId]!;
        final index = devices.indexWhere((d) => d.deviceId == deviceId);
        if (index != -1) {
          devices[index] = devices[index].copyWith(deviceName: newName);
        }
      }

      LoggerService.info('Device renamed for group: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to rename device: $e');
      return false;
    }
  }

  /// Clear cache
  void clearCache() {
    _deviceCache.clear();
  }
}
