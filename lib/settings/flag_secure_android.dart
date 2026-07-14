import 'package:caravella_core/caravella_core.dart';
import 'package:flag_secure/flag_secure.dart';

class FlagSecureAndroid {
  static Future<void> setFlagSecure(bool enabled) async {
    try {
      if (enabled) {
        await FlagSecure.set();
      } else {
        await FlagSecure.unset();
      }
    } catch (e) {
      LoggerService.warning(
        'Failed to ${enabled ? 'enable' : 'disable'} FLAG_SECURE: $e',
        name: 'settings.flag_secure',
      );
    }
  }
}
