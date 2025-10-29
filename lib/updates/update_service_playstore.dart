import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:play_store_updates/play_store_updates.dart' as psu;
import 'update_service_interface.dart';

/// Play Store implementation of UpdateService.
///
/// This wraps the play_store_updates package and adapts it to our interface.
class PlayStoreUpdateService implements UpdateService {
  const PlayStoreUpdateService();

  @override
  Future<bool> shouldCheckForUpdate() =>
      psu.AppUpdateService.shouldCheckForUpdate();

  @override
  Future<void> recordUpdateCheck() => psu.AppUpdateService.recordUpdateCheck();

  @override
  Future<Map<String, dynamic>?> checkForUpdate() async {
    final info = await psu.AppUpdateService.checkForUpdate();
    if (info == null) return null;

    return {
      'available': true,
      'version': info.availableVersionCode?.toString(),
      'priority': info.updatePriority,
      'immediateAllowed': info.immediateUpdateAllowed,
      'flexibleAllowed': info.flexibleUpdateAllowed,
    };
  }

  @override
  Future<bool> startFlexibleUpdate() =>
      psu.AppUpdateService.startFlexibleUpdate();

  @override
  Future<bool> completeFlexibleUpdate() =>
      psu.AppUpdateService.completeFlexibleUpdate();

  @override
  Future<bool> startImmediateUpdate() =>
      psu.AppUpdateService.startImmediateUpdate();

  @override
  Future<Map<String, dynamic>> getUpdateStatus() =>
      psu.AppUpdateService.getUpdateStatus();
}

/// Play Store implementation of UpdateNotifier.
class PlayStoreUpdateNotifier extends ChangeNotifier implements UpdateNotifier {
  final psu.AppUpdateNotifier _notifier = psu.AppUpdateNotifier();

  PlayStoreUpdateNotifier() {
    _notifier.addListener(notifyListeners);
  }

  @override
  bool get isChecking => _notifier.isChecking;

  @override
  bool get updateAvailable => _notifier.updateAvailable;

  @override
  String? get availableVersion => _notifier.availableVersion;

  @override
  int? get updatePriority => _notifier.updatePriority;

  @override
  bool get immediateAllowed => _notifier.immediateAllowed;

  @override
  bool get flexibleAllowed => _notifier.flexibleAllowed;

  @override
  bool get isDownloading => _notifier.isDownloading;

  @override
  bool get isInstalling => _notifier.isInstalling;

  @override
  String? get error => _notifier.error;

  @override
  Future<void> checkForUpdate() => _notifier.checkForUpdate();

  @override
  Future<bool> startFlexibleUpdate() => _notifier.startFlexibleUpdate();

  @override
  Future<bool> completeFlexibleUpdate() => _notifier.completeFlexibleUpdate();

  @override
  Future<bool> startImmediateUpdate() => _notifier.startImmediateUpdate();

  @override
  void clearError() => _notifier.clearError();

  @override
  void reset() => _notifier.reset();

  @override
  void dispose() {
    _notifier.removeListener(notifyListeners);
    _notifier.dispose();
    super.dispose();
  }
}

/// Initialize the logger adapter for the play_store_updates package.
void initializePlayStoreUpdatesLogger() {
  psu.LoggerAdapter.configure(
    onInfo: LoggerService.info,
    onWarning: LoggerService.warning,
  );
}
