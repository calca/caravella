/// Types of sync events that can occur
enum SyncEventType {
  expenseAdded,
  expenseUpdated,
  expenseDeleted,
  participantAdded,
  participantUpdated,
  participantDeleted,
  groupMetadataUpdated,
  fullSync,
}

/// Sync event data model for realtime updates
class SyncEvent {
  /// Type of sync event
  final SyncEventType type;

  /// Group ID this event belongs to
  final String groupId;

  /// Timestamp of the event
  final DateTime timestamp;

  /// Device ID that generated the event
  final String deviceId;

  /// Encrypted payload (JSON serialized and encrypted with groupKey)
  final String encryptedPayload;

  /// Event sequence number for ordering
  final int sequenceNumber;

  SyncEvent({
    required this.type,
    required this.groupId,
    required this.deviceId,
    required this.encryptedPayload,
    required this.sequenceNumber,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'groupId': groupId,
        'timestamp': timestamp.toIso8601String(),
        'deviceId': deviceId,
        'encryptedPayload': encryptedPayload,
        'sequenceNumber': sequenceNumber,
      };

  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      type: SyncEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncEventType.fullSync,
      ),
      groupId: json['groupId'] as String,
      deviceId: json['deviceId'] as String,
      encryptedPayload: json['encryptedPayload'] as String,
      sequenceNumber: json['sequenceNumber'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'SyncEvent('
      'type: ${type.name}, '
      'groupId: $groupId, '
      'deviceId: $deviceId, '
      'sequenceNumber: $sequenceNumber)';
}

/// Sync status for a group
enum SyncStatus {
  synced,
  syncing,
  error,
  disabled,
}

/// Group sync state model
class GroupSyncState {
  final String groupId;
  final SyncStatus status;
  final DateTime? lastSyncTimestamp;
  final String? errorMessage;
  final int lastSequenceNumber;

  const GroupSyncState({
    required this.groupId,
    required this.status,
    this.lastSyncTimestamp,
    this.errorMessage,
    this.lastSequenceNumber = 0,
  });

  GroupSyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTimestamp,
    String? errorMessage,
    int? lastSequenceNumber,
  }) {
    return GroupSyncState(
      groupId: groupId,
      status: status ?? this.status,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      errorMessage: errorMessage,
      lastSequenceNumber: lastSequenceNumber ?? this.lastSequenceNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'status': status.name,
        'lastSyncTimestamp': lastSyncTimestamp?.toIso8601String(),
        'errorMessage': errorMessage,
        'lastSequenceNumber': lastSequenceNumber,
      };

  factory GroupSyncState.fromJson(Map<String, dynamic> json) {
    return GroupSyncState(
      groupId: json['groupId'] as String,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.disabled,
      ),
      lastSyncTimestamp: json['lastSyncTimestamp'] != null
          ? DateTime.parse(json['lastSyncTimestamp'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      lastSequenceNumber: json['lastSequenceNumber'] as int? ?? 0,
    );
  }
}
