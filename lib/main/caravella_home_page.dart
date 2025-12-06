import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../home/new_home_v2/real_home_page.dart';
import 'route_observer.dart';

// Compile-time switch for new home page
// Use --dart-define=USE_NEW_HOME=true to enable the new home page
const bool _useNewHome = bool.fromEnvironment('USE_NEW_HOME', defaultValue: false);

/// Wrapper widget for HomePage that subscribes to route changes.
/// Refreshes the HomePage when returning from other screens.
/// 
/// Supports compile-time switching between old and new home page designs:
/// - Default (old): flutter run
/// - New design: flutter run --dart-define=USE_NEW_HOME=true
class CaravellaHomePage extends StatefulWidget {
  const CaravellaHomePage({super.key, required this.title});
  final String title;

  @override
  State<CaravellaHomePage> createState() => _CaravellaHomePageState();
}

class _CaravellaHomePageState extends State<CaravellaHomePage>
    with WidgetsBindingObserver, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {}); // trigger HomePage refresh if needed
  }

  @override
  Widget build(BuildContext context) {
    // Switch between old and new home page based on compile-time flag
    return _useNewHome ? const RealHomePage() : const HomePage();
  }
}
