import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tells Android's launch splash that Home is drawn with its groups, so it
/// can animate out (android/app/src/main/kotlin/io/caravella/egm/StartupSplash.kt).
/// Until then the splash covers the screen, at most 1.5 s from the start.
abstract final class StartupSplash {
  static const _channel = MethodChannel('io.caravella.egm/splash');
  static bool _sent = false;

  /// Only the first call does anything; safe on any platform.
  static void homeReady() {
    if (_sent) return;
    _sent = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _channel.invokeMethod<void>('homeReady').catchError((Object e) {
      LoggerService.debug('Splash not told: $e', name: 'ui.splash');
    });
  }
}
