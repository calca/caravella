import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/logger_service.dart';
import '../../security/services/secure_key_storage.dart';
import '../../security/services/encryption_service.dart';
import '../models/sync_event.dart';
import 'supabase_client_service.dart';

/// Manages realtime sync channels for expense groups
class RealtimeSyncService {
  static final RealtimeSyncService _instance =
      RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  final _supabase = SupabaseClientService();
  final _keyStorage = SecureKeyStorage();
  final _encryption = EncryptionService();

  final Map<String, RealtimeChannel> _activeChannels = {};
  final Map<String, GroupSyncState> _syncStates = {};
  final Map<String, int> _sequenceNumbers = {};

  final _syncEventController =
      StreamController<SyncEvent>.broadcast();

  /// Stream of incoming sync events
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  /// Subscribe to a group's realtime channel
  Future<bool> subscribeToGroup(String groupId) async {
    try {
      if (!_supabase.isInitialized) {
        LoggerService.warning('Supabase not initialized, cannot subscribe');
        return false;
      }

      // Check if already subscribed
      if (_activeChannels.containsKey(groupId)) {
        LoggerService.info('Already subscribed to group: $groupId');
        return true;
      }

      // Check if we have encryption key for this group
      final hasKey = await _keyStorage.hasGroupKey(groupId);
      if (!hasKey) {
        LoggerService.warning('No encryption key for group: $groupId');
        return false;
      }

      // Create channel for this group
      final channelName = 'group:$groupId';
      final channel = _supabase.client!.channel(channelName);

      // Subscribe to broadcast events
      channel.onBroadcast(
        event: 'sync_event',
        callback: (payload) => _handleSyncEvent(groupId, payload),
      );

      // Subscribe to the channel
      await channel.subscribe();

      _activeChannels[groupId] = channel;
      _syncStates[groupId] = GroupSyncState(
        groupId: groupId,
        status: SyncStatus.synced,
        lastSyncTimestamp: DateTime.now(),
      );

      LoggerService.info('Subscribed to group channel: $groupId');
      return true;
    } catch (e) {
      LoggerService.error('Failed to subscribe to group $groupId: $e');
      _syncStates[groupId] = GroupSyncState(
        groupId: groupId,
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Unsubscribe from a group's realtime channel
  Future<void> unsubscribeFromGroup(String groupId) async {
    try {
      final channel = _activeChannels.remove(groupId);
      if (channel != null) {
        await _supabase.client?.removeChannel(channel);
        LoggerService.info('Unsubscribed from group: $groupId');
      }

      _syncStates[groupId] = GroupSyncState(
        groupId: groupId,
        status: SyncStatus.disabled,
      );
    } catch (e) {
      LoggerService.error('Failed to unsubscribe from group $groupId: $e');
    }
  }

  /// Broadcast a sync event to all devices in a group
  Future<bool> broadcastSyncEvent(SyncEvent event) async {
    try {
      final channel = _activeChannels[event.groupId];
      if (channel == null) {
        LoggerService.warning('No active channel for group: ${event.groupId}');
        return false;
      }

      // Update sync state
      _syncStates[event.groupId] = _syncStates[event.groupId]!.copyWith(
        status: SyncStatus.syncing,
      );

      // Broadcast the event
      await channel.sendBroadcastMessage(
        event: 'sync_event',
        payload: event.toJson(),
      );

      // Update sync state
      _syncStates[event.groupId] = _syncStates[event.groupId]!.copyWith(
        status: SyncStatus.synced,
        lastSyncTimestamp: DateTime.now(),
        lastSequenceNumber: event.sequenceNumber,
      );

      LoggerService.info('Broadcasted sync event for group: ${event.groupId}');
      return true;
    } catch (e) {
      LoggerService.error('Failed to broadcast sync event: $e');
      _syncStates[event.groupId] = _syncStates[event.groupId]!.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Handle incoming sync event from other devices
  Future<void> _handleSyncEvent(
    String groupId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final event = SyncEvent.fromJson(payload);

      // Don't process our own events
      final deviceId = await _keyStorage.getDeviceId();
      if (event.deviceId == deviceId) {
        return;
      }

      // Check sequence number to avoid duplicates
      final lastSeq = _sequenceNumbers[groupId] ?? 0;
      if (event.sequenceNumber <= lastSeq) {
        LoggerService.info('Ignoring old sync event: ${event.sequenceNumber}');
        return;
      }

      _sequenceNumbers[groupId] = event.sequenceNumber;

      // Decrypt the payload
      final groupKey = await _keyStorage.getGroupKey(groupId);
      if (groupKey == null) {
        LoggerService.error('No group key for decrypting event');
        return;
      }

      final encryptedData = jsonDecode(event.encryptedPayload);
      final decryptedPayload = await _encryption.decryptJson(
        {
          'nonce': encryptedData['nonce'],
          'ciphertext': encryptedData['ciphertext'],
          'mac': encryptedData['mac'],
        },
        groupKey,
      );

      // Create new event with decrypted payload for local processing
      final decryptedEvent = SyncEvent(
        type: event.type,
        groupId: event.groupId,
        deviceId: event.deviceId,
        encryptedPayload: jsonEncode(decryptedPayload),
        sequenceNumber: event.sequenceNumber,
        timestamp: event.timestamp,
      );

      // Emit the event for local processing
      _syncEventController.add(decryptedEvent);

      LoggerService.info('Processed sync event: ${event.type.name}');
    } catch (e) {
      LoggerService.error('Failed to handle sync event: $e');
    }
  }

  /// Get sync state for a group
  GroupSyncState? getSyncState(String groupId) {
    return _syncStates[groupId];
  }

  /// Get next sequence number for a group
  int getNextSequenceNumber(String groupId) {
    final current = _sequenceNumbers[groupId] ?? 0;
    final next = current + 1;
    _sequenceNumbers[groupId] = next;
    return next;
  }

  /// Cleanup all subscriptions
  Future<void> dispose() async {
    for (final groupId in _activeChannels.keys.toList()) {
      await unsubscribeFromGroup(groupId);
    }
    await _syncEventController.close();
  }
}
