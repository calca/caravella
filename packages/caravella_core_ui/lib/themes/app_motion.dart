import 'package:material_ui/material_ui.dart';

/// Shared motion tokens.
class AppMotion {
  AppMotion._();

  /// Entry and exit of tall modal sheets (the expense form): a little longer
  /// than the default 250 ms with a gentle ease-out, so a sheet that covers
  /// most of the screen glides in instead of snapping up. Content that
  /// changes the layout (keyboard, location) waits for it to settle.
  static const AnimationStyle sheet = AnimationStyle(
    duration: Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
    reverseDuration: Duration(milliseconds: 220),
  );
}
