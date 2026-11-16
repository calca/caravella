import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

import 'main/app_initialization.dart';
import 'main/caravella_app.dart';
import 'main/expected_errors.dart';
import 'home/services/shortcuts_initialization.dart';
import 'home/services/app_functions_initialization.dart';

// Re-export routeObserver for backward compatibility
export 'main/route_observer.dart';

void main() async {
  // Initialize Talker logging backend before app initialization
  LoggerService.initialize(
    useHistory: AppConfig.environment != Environment.prod,
    maxHistoryItems: AppConfig.environment == Environment.dev ? 1000 : 100,
    minLevel: AppConfig.environment == Environment.prod
        ? LogLevel.warning
        : LogLevel.debug,
  );

  runZonedGuarded(
    () async {
      await AppInitialization.initialize();

      // Initialize shortcuts after app initialization
      await ShortcutsInitialization.initialize();

      // Initialize Android App Functions (no-op on non-Android platforms)
      AppFunctionsInitialization.initialize();

      runApp(const CaravellaApp());
    },
    (error, stackTrace) {
      // Uncaught async errors: an expected network failure (a map tile, a
      // remote image) is dropped, anything else is logged as an error.
      if (isExpectedNetworkError(error, stackTrace)) return;
      LoggerService.error(
        'Uncaught async error: $error',
        name: 'app.error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

/// Test entrypoint (avoids async flag secure wait & system chrome constraints in tests)
@visibleForTesting
Widget createAppForTest() {
  // Initialize environment (prod) for tests
  AppConfig.setEnvironment(Environment.prod);
  return const CaravellaApp();
}
