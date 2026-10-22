import 'package:material_ui/material_ui.dart';
import 'expense_group.dart';

/// The colors a group can have: 12 fixed, soft tints chosen for groups
/// (teal, coral, rose, apricot, sage, sky, lavender, plum, cornflower, slate,
/// sand, wheat). Pastel in the light theme (dark text on top), deep and muted
/// in the dark theme (light text on top). Stored as indices, so a group keeps
/// its tint across themes; they don't follow the app's or the wallpaper's
/// color scheme.
class ExpenseGroupColorPalette {
  static const int paletteSize = 12;

  /// Resolve the color for an expense group based on its color property.
  ///
  /// Handles both legacy ARGB color values and new palette indices.
  /// Returns [fallback] if the group has no color set or resolution fails.
  ///
  /// This is the preferred method for resolving group colors in UI code.
  static Color resolveGroupColor(
    ExpenseGroup group,
    ColorScheme colorScheme, {
    Color? fallback,
  }) {
    final effectiveFallback = fallback ?? colorScheme.surface;

    if (group.color == null) {
      return effectiveFallback;
    }

    if (isLegacyColorValue(group.color)) {
      return Color(group.color!);
    }

    return resolveColor(group.color, colorScheme) ?? effectiveFallback;
  }

  /// Whether dark text reads better than white on [color]: true when black
  /// gives the higher contrast ratio (luminance above ~0.18).
  static bool isLightColor(Color color) {
    return color.computeLuminance() > 0.179;
  }

  /// Gets the appropriate text color for content displayed on a given background.
  ///
  /// Returns a dark color for light backgrounds and a light color for dark backgrounds.
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
  }

  /// Resolve a color index to the actual color based on the theme's color scheme.
  /// Returns null if colorIndex is null or invalid.
  static Color? resolveColor(int? colorIndex, ColorScheme colorScheme) {
    if (colorIndex == null || colorIndex < 0 || colorIndex >= paletteSize) {
      return null;
    }

    final colors = _getPaletteColors(colorScheme);
    return colors[colorIndex];
  }

  /// Index order matches the old theme-role palette (primary, secondary,
  /// tertiary, error, then their containers, inverse primary, inverse
  /// surface, outline, tint), each mapped to the nearest soft tint, so
  /// saved groups keep a similar color.
  static const List<Color> _light = [
    Color(0xFFA9D8D0), // teal
    Color(0xFFF4B6A6), // coral
    Color(0xFFEDB6C4), // rose
    Color(0xFFF7CB9B), // apricot
    Color(0xFFC3DDB0), // sage
    Color(0xFFAED6EE), // sky
    Color(0xFFC9C3EE), // lavender
    Color(0xFFDDB8DD), // plum
    Color(0xFFAFC3F0), // cornflower
    Color(0xFFB9C3CC), // slate
    Color(0xFFE3D3B8), // sand
    Color(0xFFF0DF96), // wheat
  ];

  static const List<Color> _dark = [
    Color(0xFF2F5F59), // teal
    Color(0xFF7A4035), // coral
    Color(0xFF74404E), // rose
    Color(0xFF765020), // apricot
    Color(0xFF45603A), // sage
    Color(0xFF2E5A72), // sky
    Color(0xFF4C4777), // lavender
    Color(0xFF643F66), // plum
    Color(0xFF34497A), // cornflower
    Color(0xFF46525C), // slate
    Color(0xFF625641), // sand
    Color(0xFF6A5D1E), // wheat
  ];

  /// The palette for [colorScheme]'s brightness.
  static List<Color> _getPaletteColors(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark ? _dark : _light;
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
