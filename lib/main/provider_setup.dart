import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/expense_group_notifier.dart';
import '../settings/user_name_notifier.dart';
import '../state/locale_notifier.dart';
import '../state/theme_mode_notifier.dart';
import '../state/dynamic_color_notifier.dart';

/// Sets up all global providers for the app.
class ProviderSetup {
  /// Creates a MultiProvider with ExpenseGroupNotifier and UserNameNotifier.
  static Widget createProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
        ChangeNotifierProvider(create: (_) => UserNameNotifier()),
      ],
      child: child,
    );
  }

  /// Wraps the child with LocaleNotifier, ThemeModeNotifier, and DynamicColorNotifier.
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
