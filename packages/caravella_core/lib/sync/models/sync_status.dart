import 'package:caravella_core/sync/models/sync_problem.dart';
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

  /// The peer couldn't be reached (offline, another network): the normal
  /// state of device-to-device sync, not something to warn about.
  final bool unreachable;

  /// Why, for the user ([error] is the technical detail, for the log).
  final SyncProblemReason reason;

  /// The peer the exchange was with, when known.
  final String? peerId;

  /// The channel it was on (e.g. "lan"), when known.
  final String? channel;

  const SyncFailed(
    this.error, {
    this.unreachable = false,
    this.reason = SyncProblemReason.failed,
    this.peerId,
    this.channel,
  });

  @override
  String toString() =>
      'SyncFailed(error: $error${unreachable ? ', unreachable' : ''})';
}

/// A pairing handshake finished, on either side and any transport: this
/// device now trusts [deviceId] for [groupId]. Lets the invite sheet close
/// and the group's device list reload as soon as the other phone has joined.
class PeerPaired extends SyncEvent {
  final String deviceId;
  final String deviceName;
  final String groupId;

  /// The transport the handshake ran on: `"lan"` (QR code) or
  /// `"bluetooth"`. Over Bluetooth the data exchange follows on the same
  /// connection, so a UI must wait for it before closing.
  final String channel;

  const PeerPaired({
    required this.deviceId,
    required this.deviceName,
    required this.groupId,
    this.channel = 'lan',
  });

  @override
  String toString() =>
      'PeerPaired(device: $deviceId, group: $groupId, channel: $channel)';
}
