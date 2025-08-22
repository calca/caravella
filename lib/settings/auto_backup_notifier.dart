import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    notifyListeners();
  }
}