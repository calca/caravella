import 'package:flutter/material.dart';

/// Single source of truth for typography tokens shared across the app.
class AppTypography {
  AppTypography._();

  /// The app-wide font family. Referenced by [CaravellaThemes] for both the
  /// [TextTheme] and the top-level [ThemeData.fontFamily] fallback — never
  /// hardcode the family name elsewhere.
  static const String fontFamily = 'Montserrat';
}

class AppTextStyles {
  AppTextStyles._();

  /// Primary status/error message overlaid on media viewer dark
  /// backgrounds (image/video/PDF error states). Intentionally not
  /// theme-derived: media viewers render over a fixed black background
  /// regardless of the app's light/dark theme.
  static const TextStyle mediaOverlayMessage = TextStyle(
    color: Colors.white54,
    fontSize: 16,
  );

  /// Caption/filename style overlaid on media viewer dark backgrounds.
  /// Same rationale as [mediaOverlayMessage] — not theme-derived.
  static const TextStyle mediaOverlayCaption = TextStyle(
    color: Colors.white54,
    fontSize: 14,
  );

  /// Large emoji display used for the random/selected emoji shown in the
  /// group creation wizard steps.
  static const TextStyle emojiDisplay = TextStyle(fontSize: 72);

  static TextStyle? sectionTitle(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
  static TextStyle? listItem(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
  static TextStyle? listItemStrong(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
  static TextStyle? subtle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
}
