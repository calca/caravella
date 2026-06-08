import 'package:caravella_core/sync/models/sync_result.dart';

/// High-level state of the sync engine.
enum SyncStatus { idle, syncing, success, error }

/// Events emitted by the sync engine to signal lifecycle changes.
sealed class SyncEvent {
  const SyncEvent();
}

/// Sync has started on the given [channel].
class SyncStarted extends SyncEvent {
  /// The channel being used (e.g. "lan", "cloud", "nearby").
  final String channel;

  const SyncStarted(this.channel);

  @override
  String toString() => 'SyncStarted(channel: $channel)';
}

/// Sync completed successfully with the given [result].
class SyncCompleted extends SyncEvent {
  /// The outcome of the sync exchange.
  final SyncResult result;

  const SyncCompleted(this.result);

  @override
  String toString() => 'SyncCompleted(result: $result)';
}

/// Sync failed with the given [error] description.
class SyncFailed extends SyncEvent {
  /// Human-readable error description.
  final String error;

  const SyncFailed(this.error);

  @override
  String toString() => 'SyncFailed(error: $error)';
}
