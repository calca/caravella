import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlagSecureNotifier extends ChangeNotifier {
  static const String _key = 'flag_secure_enabled';
  bool _enabled = true;

  bool get enabled => _enabled;

  FlagSecureNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    notifyListeners();
  }
}
