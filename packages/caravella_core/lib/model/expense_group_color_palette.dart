import 'package:flutter/material.dart';

/// Defines a theme-aware color palette for expense groups.
/// Colors are stored as indices and resolved based on the current theme.
class ExpenseGroupColorPalette {
  static const int paletteSize = 12;

  /// Resolve a color index to the actual color based on the theme's color scheme.
  /// Returns null if colorIndex is null or invalid.
  static Color? resolveColor(int? colorIndex, ColorScheme colorScheme) {
    if (colorIndex == null || colorIndex < 0 || colorIndex >= paletteSize) {
      return null;
    }

    final colors = _getPaletteColors(colorScheme);
    return colors[colorIndex];
  }

  /// Get the palette of colors based on the current theme.
  /// These colors are theme-aware and will adapt to light/dark mode.
  static List<Color> _getPaletteColors(ColorScheme colorScheme) {
    return [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      colorScheme.errorContainer.withValues(alpha: 0.85),
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.primaryFixedDim,
      colorScheme.secondaryFixedDim,
      colorScheme.tertiaryFixed,
      colorScheme.error,
      colorScheme.outlineVariant,
      colorScheme.inversePrimary,
    ];
  }

  /// Get the list of palette colors for display in the color picker.
  static List<Color> getPaletteColors(ColorScheme colorScheme) {
    return _getPaletteColors(colorScheme);
  }

  /// Find the index of a color in the palette.
  /// Returns null if the color is not found.
  /// This is used for backward compatibility with existing ARGB color values.
  static int? findColorIndex(int argbValue, ColorScheme colorScheme) {
    final colors = _getPaletteColors(colorScheme);
    for (int i = 0; i < colors.length; i++) {
      if (colors[i].toARGB32() == argbValue) {
        return i;
      }
    }
    return null;
  }

  /// Check if a stored color value is a legacy ARGB value (not a palette index).
  /// Palette indices are stored as small positive integers (0-11).
  /// Legacy ARGB values are stored as large integers (0xAARRGGBB format).
  static bool isLegacyColorValue(int? colorValue) {
    if (colorValue == null) return false;
    // If the value is in the valid palette index range, it's not legacy
    if (colorValue >= 0 && colorValue < paletteSize) return false;
    // Otherwise, it's a legacy ARGB value
    return true;
  }

  /// Convert a legacy ARGB color value to a palette index.
  /// Returns the index of the closest matching color, or null if no good match.
  /// This is for migration of existing color values.
  static int? migrateLegacyColor(int argbValue, ColorScheme colorScheme) {
    // First try exact match
    final exactMatch = findColorIndex(argbValue, colorScheme);
    if (exactMatch != null) return exactMatch;

    // If no exact match, find the closest color by comparing RGB distance
    final legacyColor = Color(argbValue);
    final colors = _getPaletteColors(colorScheme);

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < colors.length; i++) {
      final distance = _colorDistance(legacyColor, colors[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  /// Calculate the Euclidean distance between two colors in RGB space.
  static double _colorDistance(Color c1, Color c2) {
    final r1 = (c1.r * 255.0).round() & 0xff;
    final r2 = (c2.r * 255.0).round() & 0xff;
    final g1 = (c1.g * 255.0).round() & 0xff;
    final g2 = (c2.g * 255.0).round() & 0xff;
    final b1 = (c1.b * 255.0).round() & 0xff;
    final b2 = (c2.b * 255.0).round() & 0xff;

    final dr = r1 - r2;
    final dg = g1 - g2;
    final db = b1 - b2;
    return (dr * dr + dg * dg + db * db).toDouble();
  }
}
