import 'package:flutter/material.dart';

class ThemeModeNotifier extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) changeTheme;
  const ThemeModeNotifier({
    super.key,
    required this.themeMode,
    required this.changeTheme,
    required super.child,
  });

  static ThemeModeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeNotifier>();
  }

  @override
  bool updateShouldNotify(ThemeModeNotifier oldWidget) =>
      themeMode != oldWidget.themeMode;
}
