import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Outcome of a single sync exchange with a peer.
class SyncResult {
  /// Number of operations successfully applied.
  final int applied;

  /// Number of operations skipped (e.g. already up-to-date).
  final int skipped;

  /// Number of operations that failed.
  final int errors;

  /// The sync channel used (e.g. "lan", "cloud", "nearby").
  final String channel;

  /// Identifier of the remote peer.
  final String peerId;

  /// When the sync completed.
  final DateTime syncedAt;

  /// IDs of the groups that were touched (upserted or evaluated) by this
  /// exchange — a single peer exchange can carry deltas for several groups
  /// at once, so this lets history be filtered down to one group.
  final Set<String> groupIds;

  const SyncResult({
    required this.applied,
    required this.skipped,
    required this.errors,
    required this.channel,
    required this.peerId,
    required this.syncedAt,
    this.groupIds = const {},
  });

  /// An empty result with zeroed counters and placeholder metadata.
  factory SyncResult.empty() => SyncResult(
    applied: 0,
    skipped: 0,
    errors: 0,
    channel: '',
    peerId: '',
    syncedAt: DateTime.fromMillisecondsSinceEpoch(SyncClock.nowMs(), isUtc: true),
  );

  /// Merges two results by summing their counters.
  ///
  /// Keeps the [channel] and [peerId] of [a], and the later [syncedAt].
  static SyncResult merge(SyncResult a, SyncResult b) => SyncResult(
    applied: a.applied + b.applied,
    skipped: a.skipped + b.skipped,
    errors: a.errors + b.errors,
    channel: a.channel,
    peerId: a.peerId,
    syncedAt: a.syncedAt.isAfter(b.syncedAt) ? a.syncedAt : b.syncedAt,
    groupIds: {...a.groupIds, ...b.groupIds},
  );

  @override
  String toString() =>
      'SyncResult(applied: $applied, skipped: $skipped, errors: $errors, '
      'channel: $channel, peerId: $peerId, syncedAt: $syncedAt)';
}
