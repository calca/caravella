import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';

import 'main/app_initialization.dart';
import 'main/caravella_app.dart';
import 'home/services/shortcuts_initialization.dart';

// Re-export routeObserver for backward compatibility
export 'main/route_observer.dart';
export 'main/caravella_app.dart' show rootScaffoldMessenger;

void main() async {
  await AppInitialization.initialize();

  // Initialize shortcuts after app initialization
  await ShortcutsInitialization.initialize();

  // Catch all uncaught async errors (e.g., from tile loading)
  runZonedGuarded(() => runApp(const CaravellaApp()), (error, stackTrace) {
    // Network errors from tile loading are expected and non-critical - silently ignore them
    final errorString = error.toString();
    if (errorString.contains('SocketException') ||
        errorString.contains('NetworkImageLoadException') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('HttpException') ||
        errorString.contains('Connection') ||
        errorString.contains('NetworkTileImageProvider') ||
        errorString.contains('TileLayer') ||
        errorString.contains('flutter_map') ||
        errorString.contains('MapController') ||
        errorString.contains('fitCamera') ||
        errorString.contains('_loadImage')) {
      // Silently ignore network-related and map-related errors from tile loading
      return;
    }

    // Log only unexpected errors
    LoggerService.warning('Uncaught async error: $error');
    LoggerService.warning('Stack trace: $stackTrace');
  });
}

/// Test entrypoint (avoids async flag secure wait & system chrome constraints in tests)
@visibleForTesting
Widget createAppForTest() {
  // Initialize environment (prod) for tests
  AppConfig.setEnvironment(Environment.prod);
  return const CaravellaApp();
}
