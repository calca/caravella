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
    // Log non-critical errors without crashing the UI
    LoggerService.warning('Uncaught async error: $error');
    // Network errors from tile loading are expected and non-critical
    if (!error.toString().contains('SocketException') &&
        !error.toString().contains('NetworkImageLoadException')) {
      // Only log stack trace for unexpected errors
      LoggerService.warning('Stack trace: $stackTrace');
    }
  });
}

/// Test entrypoint (avoids async flag secure wait & system chrome constraints in tests)
@visibleForTesting
Widget createAppForTest() {
  // Initialize environment (prod) for tests
  AppConfig.setEnvironment(Environment.prod);
  return const CaravellaApp();
}
