import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

/// Bridges the [SyncOrchestrator] to the UI: when a sync applies remote
/// changes, marks the touched groups updated on [ExpenseGroupNotifier], so
/// Home, Groups and an open group page reload them without a manual
/// refresh. Groups shared with this device for the first time get a pending
/// welcome (see [SharedGroupPreferences]) and are announced once through
/// [takeReceived]. (Overall sync state is shown by Home's sync button.)
///
/// It also asks for an exchange shortly after the groups change here, when
/// the app comes back and when it goes to the background: over Google
/// Drive ([SyncOrchestrator.requestCloudSync]) and with the paired phones
/// on the same Wi-Fi ([SyncOrchestrator.requestLanSync], looking for them
/// again when the app comes back); nothing on a channel that is off.
class SyncActivity extends ChangeNotifier {
  final ExpenseGroupNotifier _groups;
  SyncOrchestrator? _orchestrator;
  StreamSubscription<SyncEvent>? _sub;
  AppLifecycleListener? _lifecycle;
  int _seenRevision = 0;

  /// Set while a sync's changes are being applied to the notifier: they
  /// came from a phone, so they don't ask for a Wi-Fi exchange back.
  bool _applyingSync = false;
  final List<({String groupId, String? from})> _received = [];

  SyncActivity(this._groups);

  /// Connects to [orchestrator] (null until sync has started);
  /// reconnecting to the same one does nothing.
  void attach(SyncOrchestrator? orchestrator) {
    if (identical(orchestrator, _orchestrator)) return;
    _sub?.cancel();
    _groups.removeListener(_onGroupsChanged);
    _lifecycle?.dispose();
    _lifecycle = null;
    _orchestrator = orchestrator;
    _sub = orchestrator?.events.listen(handle);
    if (orchestrator == null) return;
    _seenRevision = _groups.revision;
    _groups.addListener(_onGroupsChanged);
    _lifecycle = AppLifecycleListener(
      onResume: () {
        orchestrator.requestCloudSync(delay: const Duration(seconds: 2));
        orchestrator.requestLanSync(
          delay: const Duration(seconds: 1),
          rediscover: true,
        );
      },
      onPause: () {
        orchestrator.requestCloudSync(delay: Duration.zero);
        orchestrator.requestLanSync(delay: Duration.zero);
      },
    );
  }

  void _onGroupsChanged() {
    if (_groups.revision == _seenRevision) return;
    _seenRevision = _groups.revision;
    _orchestrator?.requestCloudSync();
    if (!_applyingSync) _orchestrator?.requestLanSync();
  }

  /// Applies one sync event (public for tests).
  @visibleForTesting
  void handle(SyncEvent event) {
    if (event case SyncCompleted(:final result) when result.applied > 0) {
      _applyingSync = true;
      try {
        for (final id in result.groupIds) {
          _groups.notifyGroupUpdated(id);
        }
      } finally {
        _applyingSync = false;
      }
      // From the user's own devices (Google Drive): no "shared with you".
      if (result.newGroupIds.isNotEmpty && result.channel != 'cloud') {
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
    _groups.removeListener(_onGroupsChanged);
    _lifecycle?.dispose();
    super.dispose();
  }
}
