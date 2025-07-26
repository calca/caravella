import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class FlagSecureAndroid {
  static Future<void> setFlagSecure(bool enabled) async {
    try {
      if (enabled) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    } catch (_) {}
  }
}
