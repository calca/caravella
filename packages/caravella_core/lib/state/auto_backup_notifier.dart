import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caravella_core/services/backup_service.dart';

class AutoBackupNotifier extends ChangeNotifier {
  static const String _key = 'auto_backup_enabled';
  bool _enabled = false;

  bool get enabled => _enabled;

  AutoBackupNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? false;

    // Sync with platform-specific backup state
    try {
      final platformEnabled = await BackupService.isBackupEnabled();
      if (_enabled != platformEnabled) {
        // Update local preference to match platform state
        await prefs.setBool(_key, platformEnabled);
        _enabled = platformEnabled;
      }
    } catch (e) {
      // If platform check fails, keep local preference
    }

    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    try {
      // First try to set the platform backup state
      final success = await BackupService.setBackupEnabled(value);

      if (success) {
        _enabled = value;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_key, value);

        // Request immediate backup if enabling on Android
        if (value) {
          await BackupService.requestBackup();
        }
      }
    } catch (e) {
      // If platform setting fails, don't update local state
    }

    notifyListeners();
  }
}
