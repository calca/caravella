import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tells Android the app's theme choice ("light", "dark" or "system", the
/// `theme_mode` preference), so the system draws the launch splash and the
/// window behind Flutter in it too: with the phone in dark mode and the app
/// in light, coming back from the launcher no longer shows a dark window
/// before the light Home. Android 12+; nothing elsewhere
/// (android/app/src/main/kotlin/io/caravella/egm/AppNightMode.kt).
abstract final class AppNightMode {
  static const _channel = MethodChannel('io.caravella.egm/night_mode');

  static void apply(String themeMode) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _channel.invokeMethod<bool>('apply', {'themeMode': themeMode}).catchError((
      Object e,
    ) {
      LoggerService.debug('Night mode not set: $e', name: 'settings');
      return false;
    });
  }
}
