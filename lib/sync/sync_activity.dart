import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

/// What the app shows about sync for one group.
enum GroupSyncState {
  /// Nothing known yet this session (or sync off).
  idle,

  /// A sync is running.
  syncing,

  /// The last sync touching this group went fine.
  synced,

  /// The last sync failed (or had errors for this group).
  error,
}

/// Bridges the [SyncOrchestrator] to the UI:
/// - when a sync applies remote changes, marks the touched groups updated on
///   [ExpenseGroupNotifier], so Home, Groups and an open group page reload
///   them without a manual refresh;
/// - keeps a per-group [GroupSyncState] for the "Shared" badge.
///
/// [SyncStarted] / [SyncFailed] don't say which group they concern, so they
/// apply to every group (only shared groups show the state).
class SyncActivity extends ChangeNotifier {
  final ExpenseGroupNotifier _groups;
  SyncOrchestrator? _orchestrator;
  StreamSubscription<SyncEvent>? _sub;

  bool _syncing = false;
  bool _lastFailed = false;
  final Map<String, GroupSyncState> _byGroup = {};

  SyncActivity(this._groups);

  /// Connects to [orchestrator] (null until sync has started, or on the
  /// JSON backend); reconnecting to the same one does nothing.
  void attach(SyncOrchestrator? orchestrator) {
    if (identical(orchestrator, _orchestrator)) return;
    _sub?.cancel();
    _orchestrator = orchestrator;
    _sub = orchestrator?.events.listen(handle);
  }

  /// The state to show for [groupId].
  GroupSyncState stateOf(String groupId) {
    if (_syncing) return GroupSyncState.syncing;
    return _byGroup[groupId] ??
        (_lastFailed ? GroupSyncState.error : GroupSyncState.idle);
  }

  /// Applies one sync event (public for tests).
  @visibleForTesting
  void handle(SyncEvent event) {
    switch (event) {
      case SyncStarted():
        _syncing = true;
      case SyncFailed():
        _syncing = false;
        _lastFailed = true;
        _byGroup.clear();
      case SyncCompleted(:final result):
        _syncing = false;
        _lastFailed = false;
        for (final id in result.groupIds) {
          _byGroup[id] = result.errors > 0
              ? GroupSyncState.error
              : GroupSyncState.synced;
        }
        if (result.applied > 0) {
          for (final id in result.groupIds) {
            _groups.notifyGroupUpdated(id);
          }
        }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
