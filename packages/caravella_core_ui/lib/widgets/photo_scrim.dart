import 'package:material_ui/material_ui.dart';

/// The one dark scrim used over group photos, so every photo card reads the
/// same (white text, same darkness) in light and dark theme.
///
/// Darkness levels: [textAlpha] behind any text — enough for white text to
/// reach WCAG AA (≥4.5:1) even over a pure white photo — and [maxAlpha] at
/// the bottom.
class PhotoScrim {
  PhotoScrim._();

  static const double textAlpha = 0.55;
  static const double maxAlpha = 0.80;

  /// Text only at the bottom (Groups tiles): clean photo at the top.
  static const LinearGradient bottom = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x8C000000), Color(0xCC000000)],
    stops: [0.25, 0.55, 1.0],
  );

  /// Text from top to bottom (Home card): text-level darkness everywhere,
  /// deepening towards the bottom.
  static const LinearGradient full = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x8C000000), Color(0x8C000000), Color(0xCC000000)],
    stops: [0.0, 0.5, 1.0],
  );
}
