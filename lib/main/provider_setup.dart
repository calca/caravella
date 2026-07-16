import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_manager.dart';
import '../settings/state/group_type_templates_notifier.dart';
import '../sync/sync_bootstrap.dart';

/// Sets up all global providers for the app.
class ProviderSetup {
  /// Creates a MultiProvider with ExpenseGroupNotifier and UserNameNotifier.
  static Widget createProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final notifier = ExpenseGroupNotifier();
            notifier.setShortcutsUpdateCallback(() {
              unawaited(PlatformShortcutsManager.updateShortcuts());
              unawaited(PlatformHomeWidgetManager.updateHomeWidgets());
            });
            // Register callback to cancel notification when archiving
            notifier.setNotificationCancelCallback((groupId) async {
              await NotificationManager().cancelNotificationForGroup(groupId);
            });
            return notifier;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserNameNotifier()),
        ChangeNotifierProvider(create: (_) => GroupTypeTemplatesNotifier()),
        // Built asynchronously so LAN/mDNS setup never blocks the first
        // frame; consumers see null until initialization completes (or
        // permanently, on the JSON backend where sync isn't available).
        FutureProvider<SyncOrchestrator?>(
          create: (_) => SyncBootstrap.initialize(),
          initialData: null,
        ),
      ],
      child: child,
    );
  }

  /// Wraps the child with LocaleNotifier, ThemeModeNotifier and DynamicColorNotifier.
  static Widget wrapWithNotifiers({
    required Widget child,
    required String locale,
    required Function(String) onLocaleChange,
    required ThemeMode themeMode,
    required Function(ThemeMode) onThemeChange,
    required bool dynamicColorEnabled,
    required Function(bool) onDynamicColorChange,
  }) {
    return LocaleNotifier(
      locale: locale,
      changeLocale: onLocaleChange,
      child: ThemeModeNotifier(
        themeMode: themeMode,
        changeTheme: onThemeChange,
        child: DynamicColorNotifier(
          dynamicColorEnabled: dynamicColorEnabled,
          changeDynamicColor: onDynamicColorChange,
          child: child,
        ),
      ),
    );
  }
}
