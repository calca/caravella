/// How a shared group's sync is doing, for the dot on its "Shared" badge.
enum GroupSyncHealth {
  /// Synced within [GroupSyncStatus.staleAfter].
  ok,

  /// The last exchange that carried this group had errors.
  failed,

  /// Never synced, or not since [GroupSyncStatus.staleAfter].
  stale,
}

/// A shared group's sync state: its [health] and when it last synced.
class GroupSyncStatus {
  /// Past this, a group's data may be out of date.
  static const Duration staleAfter = Duration(hours: 24);

  final GroupSyncHealth health;
  final DateTime? lastSyncAt;

  const GroupSyncStatus(this.health, this.lastSyncAt);

  /// The status from the last exchange that carried the group
  /// ([lastSyncAt], [lastHadErrors]) at time [now].
  factory GroupSyncStatus.from({
    required DateTime? lastSyncAt,
    required bool lastHadErrors,
    required DateTime now,
  }) {
    if (lastSyncAt == null) {
      return const GroupSyncStatus(GroupSyncHealth.stale, null);
    }
    if (lastHadErrors) {
      return GroupSyncStatus(GroupSyncHealth.failed, lastSyncAt);
    }
    return GroupSyncStatus(
      now.difference(lastSyncAt) > staleAfter
          ? GroupSyncHealth.stale
          : GroupSyncHealth.ok,
      lastSyncAt,
    );
  }
}
