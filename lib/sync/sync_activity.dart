import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

/// Bridges the [SyncOrchestrator] to the UI: when a sync applies remote
/// changes, marks the touched groups updated on [ExpenseGroupNotifier], so
/// Home, Groups and an open group page reload them without a manual
/// refresh. Groups shared with this device for the first time get a pending
/// welcome (see [SharedGroupPreferences]) and are announced once through
/// [takeReceived]. (Overall sync state is shown by Home's sync button.)
class SyncActivity extends ChangeNotifier {
  final ExpenseGroupNotifier _groups;
  SyncOrchestrator? _orchestrator;
  StreamSubscription<SyncEvent>? _sub;
  final List<({String groupId, String? from})> _received = [];

  SyncActivity(this._groups);

  /// Connects to [orchestrator] (null until sync has started, or on the
  /// JSON backend); reconnecting to the same one does nothing.
  void attach(SyncOrchestrator? orchestrator) {
    if (identical(orchestrator, _orchestrator)) return;
    _sub?.cancel();
    _orchestrator = orchestrator;
    _sub = orchestrator?.events.listen(handle);
  }

  /// Applies one sync event (public for tests).
  @visibleForTesting
  void handle(SyncEvent event) {
    if (event case SyncCompleted(:final result) when result.applied > 0) {
      for (final id in result.groupIds) {
        _groups.notifyGroupUpdated(id);
      }
      if (result.newGroupIds.isNotEmpty) {
        for (final id in result.newGroupIds) {
          if (PreferencesService.isInitialized) {
            PreferencesService.instance.sharedGroups.addPendingWelcome(
              id,
              result.peerName ?? '',
            );
          }
          _received.add((groupId: id, from: result.peerName));
        }
        notifyListeners();
      }
    }
  }

  /// Groups received since the last call (to announce them once), with the
  /// name of the device that shared them when known.
  List<({String groupId, String? from})> takeReceived() {
    final taken = List.of(_received);
    _received.clear();
    return taken;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
