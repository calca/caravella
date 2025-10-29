import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';

import 'main/app_initialization.dart';
import 'main/caravella_app.dart';
import 'services/shortcuts_initialization.dart';

// Re-export routeObserver for backward compatibility
export 'main/route_observer.dart';
export 'main/caravella_app.dart' show rootScaffoldMessenger;

void main() async {
  await AppInitialization.initialize();

  // Initialize shortcuts after app initialization
  ShortcutsInitialization.initialize();

  runApp(const CaravellaApp());
}

/// Test entrypoint (avoids async flag secure wait & system chrome constraints in tests)
@visibleForTesting
Widget createAppForTest() {
  // Initialize environment (prod) for tests
  AppConfig.setEnvironment(Environment.prod);
  return const CaravellaApp();
}
