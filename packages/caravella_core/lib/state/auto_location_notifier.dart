import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';

class AutoLocationNotifier extends ChangeNotifier {
  bool _enabled = false;

  bool get enabled => _enabled;

  AutoLocationNotifier() {
    _load();
  }

  Future<void> _load() async {
    _enabled = PreferencesService.instance.autoLocation.get();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await PreferencesService.instance.autoLocation.set(value);
    notifyListeners();
  }
}
