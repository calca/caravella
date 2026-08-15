import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'app_update_service.dart';

/// State notifier for managing app update state.
///
/// Provides reactive state management for:
/// - Update availability
/// - Update download progress
/// - Update installation status
class AppUpdateNotifier extends ChangeNotifier {
  bool _isChecking = false;
  bool _updateAvailable = false;
  String? _availableVersion;
  int? _updatePriority;
  bool _immediateAllowed = false;
  bool _flexibleAllowed = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  bool _updateDownloaded = false;
  String? _error;

  StreamSubscription<InstallStatus>? _installStatusSub;

  AppUpdateNotifier() {
    _installStatusSub = AppUpdateService.installUpdateStream.listen(
      _onInstallStatusChanged,
    );
    // A flexible update may have finished downloading while this notifier
    // didn't exist yet (e.g. app was closed and reopened) — pick that up.
    unawaited(_checkPendingInstall());
  }

  bool get isChecking => _isChecking;
  bool get updateAvailable => _updateAvailable;
  String? get availableVersion => _availableVersion;
  int? get updatePriority => _updatePriority;
  bool get immediateAllowed => _immediateAllowed;
  bool get flexibleAllowed => _flexibleAllowed;
  bool get isDownloading => _isDownloading;
  bool get isInstalling => _isInstalling;
  bool get updateDownloaded => _updateDownloaded;
  String? get error => _error;

  Future<void> _checkPendingInstall() async {
    final ready = await AppUpdateService.isUpdateReadyToInstall();
    if (ready && !_updateDownloaded) {
      _updateDownloaded = true;
      notifyListeners();
    }
  }

  void _onInstallStatusChanged(InstallStatus status) {
    switch (status) {
      case InstallStatus.downloading:
        _isDownloading = true;
        break;
      case InstallStatus.downloaded:
        _isDownloading = false;
        _updateDownloaded = true;
        break;
      case InstallStatus.installing:
        _isInstalling = true;
        break;
      case InstallStatus.installed:
        _isInstalling = false;
        _updateDownloaded = false;
        _updateAvailable = false;
        break;
      case InstallStatus.failed:
      case InstallStatus.canceled:
        _isDownloading = false;
        _isInstalling = false;
        _error = 'Update install failed';
        break;
      case InstallStatus.pending:
      case InstallStatus.unknown:
        break;
    }
    notifyListeners();
  }

  /// Check for available updates.
  Future<void> checkForUpdate() async {
    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      final status = await AppUpdateService.getUpdateStatus();

      _updateAvailable = status['available'] as bool;
      _availableVersion = status['version'] as String?;
      _updatePriority = status['priority'] as int?;
      _immediateAllowed = status['immediateAllowed'] as bool;
      _flexibleAllowed = status['flexibleAllowed'] as bool;
    } catch (e) {
      _error = e.toString();
      _updateAvailable = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Start a flexible update.
  Future<bool> startFlexibleUpdate() async {
    _isDownloading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await AppUpdateService.startFlexibleUpdate();
      if (!success) {
        _error = 'Failed to start update';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Complete a flexible update (install and restart).
  Future<bool> completeFlexibleUpdate() async {
    _isInstalling = true;
    _error = null;
    notifyListeners();

    try {
      final success = await AppUpdateService.completeFlexibleUpdate();
      if (!success) {
        _error = 'Failed to complete update';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isInstalling = false;
      notifyListeners();
    }
  }

  /// Start an immediate update.
  Future<bool> startImmediateUpdate() async {
    _isInstalling = true;
    _error = null;
    notifyListeners();

    try {
      final success = await AppUpdateService.startImmediateUpdate();
      if (!success) {
        _error = 'Failed to start immediate update';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isInstalling = false;
      notifyListeners();
    }
  }

  /// Clear error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset all state.
  void reset() {
    _isChecking = false;
    _updateAvailable = false;
    _availableVersion = null;
    _updatePriority = null;
    _immediateAllowed = false;
    _flexibleAllowed = false;
    _isDownloading = false;
    _isInstalling = false;
    _updateDownloaded = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _installStatusSub?.cancel();
    super.dispose();
  }
}
