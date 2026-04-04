import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNameNotifier extends ChangeNotifier {
  static const String _key = 'user_name';
  String _name = '';

  String get name => _name;

  UserNameNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_key) ?? '';
    notifyListeners();
  }

  Future<void> setName(String value) async {
    _name = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _name);
    notifyListeners();
  }

  bool get hasName => _name.isNotEmpty;
}
