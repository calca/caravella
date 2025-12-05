import 'package:flutter/material.dart';

class LocaleNotifier extends InheritedWidget {
  final String locale;
  final void Function(String) changeLocale;
  const LocaleNotifier({
    super.key,
    required this.locale,
    required this.changeLocale,
    required super.child,
  });

  static LocaleNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleNotifier>();
  }

  @override
  bool updateShouldNotify(LocaleNotifier oldWidget) =>
      locale != oldWidget.locale;
}
