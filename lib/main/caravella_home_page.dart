import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../services/notification_manager.dart';
import 'route_observer.dart';

/// Wrapper widget for HomePage that subscribes to route changes.
/// Refreshes the HomePage when returning from other screens.
class CaravellaHomePage extends StatefulWidget {
  const CaravellaHomePage({super.key, required this.title});
  final String title;

  @override
  State<CaravellaHomePage> createState() => _CaravellaHomePageState();
}

class _CaravellaHomePageState extends State<CaravellaHomePage>
    with WidgetsBindingObserver, RouteAware {
  bool _notificationsRestored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);

    // Restore notifications on first build (when context is available)
    if (!_notificationsRestored && mounted) {
      _notificationsRestored = true;
      // Run after frame to ensure context is fully ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          NotificationManager.restoreNotifications(context);
        }
      });
    }
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
    return const HomePage();
  }
}
