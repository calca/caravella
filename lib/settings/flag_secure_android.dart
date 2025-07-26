import 'package:flag_secure/flag_secure.dart';

class FlagSecureAndroid {
  static Future<void> setFlagSecure(bool enabled) async {
    try {
      if (enabled) {
        await FlagSecure.set();
      } else {
        await FlagSecure.unset();
      }
    } catch (_) {}
  }
}
