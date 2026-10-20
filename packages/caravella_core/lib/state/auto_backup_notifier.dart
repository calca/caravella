import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caravella_core/services/backup_service.dart';

/// The "Android backup" switch (iCloud on iOS) and when it last ran.
///
/// On Android the preference itself is what turns cloud backups on or off:
/// the app's backup agent reads it (key `auto_backup_enabled`, on unless
/// turned off) and skips cloud backups when off. On iOS the platform's
/// backup exclusion is the source of truth.
class AutoBackupNotifier extends ChangeNotifier {
  static const String _key = 'auto_backup_enabled';
  bool _enabled = true;
  DateTime? _lastBackup;

  /// Test override for the platform check.
  @visibleForTesting
  static bool? debugIsIOS;

  bool get enabled => _enabled;

  /// Last cloud backup (Android), `null` if none recorded yet.
  DateTime? get lastBackup => _lastBackup;

  bool get _isIOS => debugIsIOS ?? (!kIsWeb && Platform.isIOS);

  AutoBackupNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;

    if (_isIOS) {
      try {
        final platformEnabled = await BackupService.isBackupEnabled();
        if (_enabled != platformEnabled) {
          await prefs.setBool(_key, platformEnabled);
          _enabled = platformEnabled;
        }
      } catch (e) {
        // If platform check fails, keep local preference
      }
    } else {
      _lastBackup = await BackupService.lastBackupTime();
    }

    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    try {
      final success = await BackupService.setBackupEnabled(value);
      if (success) {
        _enabled = value;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_key, value);
      }
    } catch (e) {
      // If platform setting fails, don't update local state
    }

    notifyListeners();
  }
}
