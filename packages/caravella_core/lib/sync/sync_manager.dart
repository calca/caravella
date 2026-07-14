import 'dart:async';

import 'package:caravella_core/data/sqlite_expense_group_repository.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/conflict_resolver.dart';
import 'package:caravella_core/sync/delta_builder.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/models/sync_status.dart';
import 'package:caravella_core/sync/sync_dao.dart';

/// Main coordinator for the sync subsystem.
///
/// Owns a [DeltaBuilder] and a [ConflictResolver] and exposes a
/// high-level API for exchanging deltas with remote peers.
///
/// Transport channels (LAN, cloud, NearbyShare, …) are not part of this
/// class — they will push received deltas into [syncWithPeer] and pull
/// outgoing deltas via [getOutgoingDelta].
class SyncManager {
  static const _tag = 'sync.manager';

  final SqliteExpenseGroupRepository _repository;

  late final SyncDao _syncDao;
  late final DeltaBuilder _deltaBuilder;
  late final ConflictResolver _conflictResolver;

  final StreamController<SyncEvent> _eventController =
      StreamController<SyncEvent>.broadcast();

  bool _started = false;

  /// Creates a [SyncManager] backed by the given [repository].
  SyncManager({required SqliteExpenseGroupRepository repository})
      : _repository = repository;

  /// Stream of [SyncEvent]s for UI or other listeners.
  Stream<SyncEvent> get events => _eventController.stream;

  /// Whether the manager has been started.
  bool get isStarted => _started;

  /// Initializes internal components and starts listening for sync events.
  ///
  /// Must be called before any other method. Safe to call multiple times —
  /// subsequent calls are no-ops.
  Future<void> start() async {
    if (_started) return;

    final db = await _repository.database;

    _syncDao = SyncDao(db);
    _deltaBuilder = DeltaBuilder(
      syncDao: _syncDao,
      repository: _repository,
    );
    _conflictResolver = ConflictResolver(
      syncDao: _syncDao,
    );

    _started = true;
    LoggerService.info('SyncManager started', name: _tag);
  }

  /// Stops the manager and releases resources.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    LoggerService.info('SyncManager stopped', name: _tag);
  }

  /// Disposes the event stream. Call when the manager will no longer be used.
  void dispose() {
    _eventController.close();
  }

  /// Processes an incoming [remoteDelta] from [peerId] received via [channel].
  ///
  /// Returns a [SyncResult] summarizing applied / skipped / errored groups.
  /// Also broadcasts [SyncEvent]s on the [events] stream.
  Future<SyncResult> syncWithPeer(
    String peerId,
    Map<String, dynamic> remoteDelta,
    String channel,
  ) async {
    _ensureStarted();
    _eventController.add(SyncStarted(channel));

    try {
      final db = await _repository.database;

      final result = await _conflictResolver.applyDelta(
        db,
        remoteDelta,
        channel,
      );

      _eventController.add(SyncCompleted(result));

      LoggerService.info(
        'Sync with peer=$peerId on $channel complete: $result',
        name: _tag,
      );

      return result;
    } catch (e, st) {
      LoggerService.error(
        'Sync with peer=$peerId failed',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      _eventController.add(SyncFailed(e.toString()));
      rethrow;
    }
  }

  /// Builds the outgoing delta payload for the given [peerId].
  ///
  /// Only groups changed since the last recorded sync with this peer are
  /// included.
  Future<Map<String, dynamic>> getOutgoingDelta(String peerId) async {
    _ensureStarted();
    final db = await _repository.database;
    return _deltaBuilder.buildDelta(db, peerId);
  }

  /// Returns the last sync time with [peerId], or `null` if never synced.
  Future<DateTime?> lastSyncTime(String peerId) async {
    _ensureStarted();
    final ms = await _syncDao.getLastSyncTime(peerId);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  // -------------------------------------------------------------------------
  // Internal
  // -------------------------------------------------------------------------

  void _ensureStarted() {
    if (!_started) {
      throw StateError(
        'SyncManager has not been started. Call start() first.',
      );
    }
  }
}
