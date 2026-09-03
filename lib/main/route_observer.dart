import 'package:material_ui/material_ui.dart';

/// Global route observer for tracking navigation events.
/// Used by pages like HomePage to refresh when popping back.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
