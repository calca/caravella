import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backup_service.dart';

class AutoBackupNotifier extends ChangeNotifier {
  static const String _key = 'auto_backup_enabled';
  static const String _lastAutoBackupKey = 'last_auto_backup_timestamp';
  static const String _lastManualBackupKey = 'last_manual_backup_timestamp';
  
  bool _enabled = false;
  DateTime? _lastAutoBackup;
  DateTime? _lastManualBackup;

  bool get enabled => _enabled;
  DateTime? get lastAutoBackup => _lastAutoBackup;
  DateTime? get lastManualBackup => _lastManualBackup;

  AutoBackupNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? false;
    
    // Load backup timestamps
    final lastAutoBackupMs = prefs.getInt(_lastAutoBackupKey);
    if (lastAutoBackupMs != null) {
      _lastAutoBackup = DateTime.fromMillisecondsSinceEpoch(lastAutoBackupMs);
    }
    
    final lastManualBackupMs = prefs.getInt(_lastManualBackupKey);
    if (lastManualBackupMs != null) {
      _lastManualBackup = DateTime.fromMillisecondsSinceEpoch(lastManualBackupMs);
    }
    
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
          final backupSuccess = await BackupService.requestBackup();
          if (backupSuccess) {
            // Update auto backup timestamp
            await _updateAutoBackupTimestamp();
          }
        }
      }
    } catch (e) {
      // If platform setting fails, don't update local state
    }
    
    notifyListeners();
  }

  /// Update the timestamp of the last automatic backup
  Future<void> _updateAutoBackupTimestamp() async {
    final now = DateTime.now();
    _lastAutoBackup = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAutoBackupKey, now.millisecondsSinceEpoch);
    notifyListeners();
  }

  /// Update the timestamp of the last manual backup
  Future<void> updateManualBackupTimestamp() async {
    final now = DateTime.now();
    _lastManualBackup = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastManualBackupKey, now.millisecondsSinceEpoch);
    notifyListeners();
  }
}