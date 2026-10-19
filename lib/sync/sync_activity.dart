import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

/// Bridges the [SyncOrchestrator] to the UI: when a sync applies remote
/// changes, marks the touched groups updated on [ExpenseGroupNotifier], so
/// Home, Groups and an open group page reload them without a manual
/// refresh. (Overall sync state is shown by Home's sync button.)
class SyncActivity extends ChangeNotifier {
  final ExpenseGroupNotifier _groups;
  SyncOrchestrator? _orchestrator;
  StreamSubscription<SyncEvent>? _sub;

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
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
