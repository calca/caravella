import 'dart:convert';
import '../../data/services/logger_service.dart';
import '../../data/model/expense_group.dart';
import '../../data/model/expense_details.dart';
import '../../security/services/secure_key_storage.dart';
import '../../security/services/encryption_service.dart';
import '../models/sync_event.dart';
import 'realtime_sync_service.dart';

/// Coordinates synchronization of expense group data
class GroupSyncCoordinator {
  static final GroupSyncCoordinator _instance =
      GroupSyncCoordinator._internal();
  factory GroupSyncCoordinator() => _instance;
  GroupSyncCoordinator._internal();

  final _keyStorage = SecureKeyStorage();
  final _encryption = EncryptionService();
  final _realtimeSync = RealtimeSyncService();

  /// Initialize sync for a group
  Future<bool> initializeGroupSync(String groupId) async {
    try {
      // Check if group has encryption key
      final hasKey = await _keyStorage.hasGroupKey(groupId);
      if (!hasKey) {
        LoggerService.warning('No encryption key for group: $groupId');
        return false;
      }

      // Subscribe to realtime channel
      final subscribed = await _realtimeSync.subscribeToGroup(groupId);
      if (!subscribed) {
        LoggerService.error('Failed to subscribe to group: $groupId');
        return false;
      }

      LoggerService.info('Initialized sync for group: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to initialize group sync: $e');
      return false;
    }
  }

  /// Stop sync for a group
  Future<void> stopGroupSync(String groupId) async {
    await _realtimeSync.unsubscribeFromGroup(groupId);
    LoggerService.info('Stopped sync for group: $groupId');
  }

  /// Sync an expense addition
  Future<bool> syncExpenseAdded(
    String groupId,
    ExpenseDetails expense,
  ) async {
    try {
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) {
        LoggerService.error('No device ID available');
        return false;
      }

      final groupKey = await _keyStorage.getGroupKey(groupId);
      if (groupKey == null) {
        LoggerService.error('No group key available');
        return false;
      }

      // Prepare payload
      final payload = {
        'action': 'expense_added',
        'expense': expense.toJson(),
      };

      // Encrypt payload
      final encrypted = await _encryption.encryptJson(payload, groupKey);
      final encryptedPayload = jsonEncode(encrypted);

      // Create sync event
      final event = SyncEvent(
        type: SyncEventType.expenseAdded,
        groupId: groupId,
        deviceId: deviceId,
        encryptedPayload: encryptedPayload,
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      // Broadcast event
      return await _realtimeSync.broadcastSyncEvent(event);
    } catch (e) {
      LoggerService.error('Failed to sync expense addition: $e');
      return false;
    }
  }

  /// Sync an expense update
  Future<bool> syncExpenseUpdated(
    String groupId,
    ExpenseDetails expense,
  ) async {
    try {
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) return false;

      final groupKey = await _keyStorage.getGroupKey(groupId);
      if (groupKey == null) return false;

      final payload = {
        'action': 'expense_updated',
        'expense': expense.toJson(),
      };

      final encrypted = await _encryption.encryptJson(payload, groupKey);
      final encryptedPayload = jsonEncode(encrypted);

      final event = SyncEvent(
        type: SyncEventType.expenseUpdated,
        groupId: groupId,
        deviceId: deviceId,
        encryptedPayload: encryptedPayload,
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      return await _realtimeSync.broadcastSyncEvent(event);
    } catch (e) {
      LoggerService.error('Failed to sync expense update: $e');
      return false;
    }
  }

  /// Sync an expense deletion
  Future<bool> syncExpenseDeleted(
    String groupId,
    String expenseId,
  ) async {
    try {
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) return false;

      final groupKey = await _keyStorage.getGroupKey(groupId);
      if (groupKey == null) return false;

      final payload = {
        'action': 'expense_deleted',
        'expenseId': expenseId,
      };

      final encrypted = await _encryption.encryptJson(payload, groupKey);
      final encryptedPayload = jsonEncode(encrypted);

      final event = SyncEvent(
        type: SyncEventType.expenseDeleted,
        groupId: groupId,
        deviceId: deviceId,
        encryptedPayload: encryptedPayload,
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      return await _realtimeSync.broadcastSyncEvent(event);
    } catch (e) {
      LoggerService.error('Failed to sync expense deletion: $e');
      return false;
    }
  }

  /// Sync group metadata update
  Future<bool> syncGroupMetadataUpdated(
    String groupId,
    ExpenseGroup group,
  ) async {
    try {
      final deviceId = await _keyStorage.getDeviceId();
      if (deviceId == null) return false;

      final groupKey = await _keyStorage.getGroupKey(groupId);
      if (groupKey == null) return false;

      final payload = {
        'action': 'group_metadata_updated',
        'metadata': {
          'title': group.title,
          'currency': group.currency,
          'startDate': group.startDate?.toIso8601String(),
          'endDate': group.endDate?.toIso8601String(),
          'participants': group.participants.map((p) => p.toJson()).toList(),
          'categories': group.categories.map((c) => c.toJson()).toList(),
        },
      };

      final encrypted = await _encryption.encryptJson(payload, groupKey);
      final encryptedPayload = jsonEncode(encrypted);

      final event = SyncEvent(
        type: SyncEventType.groupMetadataUpdated,
        groupId: groupId,
        deviceId: deviceId,
        encryptedPayload: encryptedPayload,
        sequenceNumber: _realtimeSync.getNextSequenceNumber(groupId),
      );

      return await _realtimeSync.broadcastSyncEvent(event);
    } catch (e) {
      LoggerService.error('Failed to sync group metadata: $e');
      return false;
    }
  }

  /// Get sync state for a group
  GroupSyncState? getGroupSyncState(String groupId) {
    return _realtimeSync.getSyncState(groupId);
  }

  /// Listen to sync events
  Stream<SyncEvent> get syncEvents => _realtimeSync.syncEvents;
}
