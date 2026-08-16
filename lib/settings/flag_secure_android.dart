import 'package:caravella_core/caravella_core.dart';
import 'package:flag_secure/flag_secure.dart';

class FlagSecureAndroid {
  /// Applies the native FLAG_SECURE toggle. Returns whether it actually
  /// succeeded, so callers can avoid persisting/announcing a state the
  /// platform never applied.
  static Future<bool> setFlagSecure(bool enabled) async {
    try {
      if (enabled) {
        await FlagSecure.set();
      } else {
        await FlagSecure.unset();
      }
      return true;
    } catch (e) {
      LoggerService.warning(
        'Failed to ${enabled ? 'enable' : 'disable'} FLAG_SECURE: $e',
        name: 'settings.flag_secure',
      );
      return false;
    }
  }
}
