import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import '../services/notification_manager.dart';

/// Sets up all global providers for the app.
class ProviderSetup {
  /// Creates a MultiProvider with ExpenseGroupNotifier and UserNameNotifier.
  static Widget createProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final notifier = ExpenseGroupNotifier();
            // Register callback to cancel notification when archiving
            notifier.setNotificationCancelCallback((groupId) async {
              await NotificationManager().cancelNotificationForGroup(groupId);
            });
            return notifier;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserNameNotifier()),
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
