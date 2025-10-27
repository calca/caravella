import 'package:flutter/material.dart';

class DynamicColorNotifier extends InheritedWidget {
  final bool dynamicColorEnabled;
  final void Function(bool) changeDynamicColor;
  const DynamicColorNotifier({
    super.key,
    required this.dynamicColorEnabled,
    required this.changeDynamicColor,
    required super.child,
  });

  static DynamicColorNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DynamicColorNotifier>();
  }

  @override
  bool updateShouldNotify(DynamicColorNotifier oldWidget) =>
      dynamicColorEnabled != oldWidget.dynamicColorEnabled;
}