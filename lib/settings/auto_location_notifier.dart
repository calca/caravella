import 'package:flutter/material.dart';
import '../data/services/preferences_service.dart';

class AutoLocationNotifier extends ChangeNotifier {
  bool _enabled = false;

  bool get enabled => _enabled;

  AutoLocationNotifier() {
    _load();
  }

  Future<void> _load() async {
    _enabled = await PreferencesService.getAutoLocationEnabled();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await PreferencesService.setAutoLocationEnabled(value);
    notifyListeners();
  }
}
