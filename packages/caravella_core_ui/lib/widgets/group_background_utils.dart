import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import '../themes/caravella_themes.dart';

/// Resolved background properties for an [ExpenseGroup].
///
/// Use [GroupBackgroundUtils.resolve] to compute these from a group and a
/// [ColorScheme], then apply them to a [BoxDecoration] or pass [gradient] and
/// [backgroundImage] to [BaseCard].
class GroupBackground {
  /// Solid background color (base layer; may be partially transparent when an
  /// image is present).
  final Color color;

  /// Gradient overlay applied on top of [backgroundImage] (or on top of
  /// [color] when there is no image). Null when the group has neither an image
  /// nor a palette color.
  final LinearGradient? gradient;

  /// Absolute path to the local image file, or null when none is set.
  final String? imagePath;

  const GroupBackground({required this.color, this.gradient, this.imagePath});

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
}

/// Utility for computing the background appearance of an [ExpenseGroup].
///
/// The rules mirror those used in [GroupCard]:
/// - **Image present**: surface veil over the image, strong enough for text
///   on any photo, ramping to nearly opaque below the text area.
/// - **Color only**: opaque palette-color-to-transparent gradient.
/// - **Neither**: plain `raisedSurface` (see [CaravellaSemanticColors]).
class GroupBackgroundUtils {
  GroupBackgroundUtils._();

  /// Builds the consistent two-stop gradient used by group cards and the
  /// detail-page header.
  ///
  /// [topColor] is shown at the very top (0 %), [bottomColor] at 65 %.
  static LinearGradient buildGradient(Color topColor, Color bottomColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
      stops: const [0.0, 0.65],
    );
  }

  /// Surface veil opacity over the top part of a photo, where the group title,
  /// dates, badges and totals sit. With `onSurface` text this keeps WCAG AA
  /// contrast (>=4.5:1) even over a pure white or pure black photo: 5.3:1 in
  /// the dark theme, 9.9:1 in the light theme.
  static const double imageTextScrimAlpha = 0.7;

  /// Gradient laid over a background photo: [imageTextScrimAlpha] down to
  /// 50 % (the text area), then nearly opaque [surface] at 65 % for the
  /// content below.
  static LinearGradient buildImageScrim(Color surface) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        surface.withValues(alpha: imageTextScrimAlpha),
        surface.withValues(alpha: imageTextScrimAlpha),
        surface.withValues(alpha: 0.95),
      ],
      stops: const [0.0, 0.5, 0.65],
    );
  }

  /// Resolves [GroupBackground] for [group] using the given [colorScheme].
  ///
  /// Pass [baseColor] to override the surface color used as the gradient
  /// target (defaults to [ColorScheme.surface]).
  static GroupBackground resolve(
    ExpenseGroup group,
    ColorScheme colorScheme, {
    Color? baseColor,
  }) {
    final surface = baseColor ?? colorScheme.surface;
    final imagePath = (group.file != null && group.file!.isNotEmpty)
        ? group.file
        : null;

    if (imagePath != null && File(imagePath).existsSync()) {
      // Image present: readable veil over the text area → nearly-opaque bottom
      return GroupBackground(
        color: surface.withValues(alpha: imageTextScrimAlpha),
        gradient: buildImageScrim(surface),
        imagePath: imagePath,
      );
    }

    if (group.color != null) {
      final Color groupColor;
      if (ExpenseGroupColorPalette.isLegacyColorValue(group.color)) {
        groupColor = Color(group.color!);
      } else {
        groupColor =
            ExpenseGroupColorPalette.resolveColor(group.color, colorScheme) ??
            colorScheme.primary;
      }
      // Color only: opaque color top → transparent color bottom
      return GroupBackground(
        color: groupColor,
        gradient: buildGradient(
          groupColor.withValues(alpha: 0.95),
          groupColor.withValues(alpha: 0.1),
        ),
      );
    }

    // Fallback: plain surface
    return GroupBackground(color: colorScheme.raisedSurface);
  }
}
