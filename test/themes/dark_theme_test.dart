import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

void main() {
  group('Dark Theme Tests', () {
    late ColorScheme darkColorScheme;

    setUp(() {
      darkColorScheme = CaravellaThemes.dark.colorScheme;
    });

    test('should have appropriate surface colors for readability', () {
      // Soft dark theme - surface should be 0xFF181A1B
      expect(darkColorScheme.surface, equals(const Color(0xFF181A1B)));

      // SurfaceDim should be slightly darker than surface
      expect(
        darkColorScheme.surfaceDim.toARGB32(),
        lessThan(darkColorScheme.surface.toARGB32()),
      );

      // SurfaceContainerLowest should be darker than surface
      expect(
        darkColorScheme.surfaceContainerLowest.toARGB32(),
        lessThan(darkColorScheme.surface.toARGB32()),
      );

      // SurfaceContainer (card color) should be 0xFF242627
      expect(darkColorScheme.surfaceContainer, equals(const Color(0xFF242627)));
    });

    test('should maintain proper surface container hierarchy', () {
      // Surface containers should have progressive lightness for elevation
      expect(
        darkColorScheme.surfaceContainerLowest.toARGB32(),
        lessThan(darkColorScheme.surfaceContainerLow.toARGB32()),
      );
      expect(
        darkColorScheme.surfaceContainerLow.toARGB32(),
        lessThan(darkColorScheme.surfaceContainer.toARGB32()),
      );
      expect(
        darkColorScheme.surfaceContainer.toARGB32(),
        lessThan(darkColorScheme.surfaceContainerHigh.toARGB32()),
      );
      expect(
        darkColorScheme.surfaceContainerHigh.toARGB32(),
        lessThan(darkColorScheme.surfaceContainerHighest.toARGB32()),
      );
    });

    test('should have visible outline colors', () {
      // Outline should not be too dark (0xFF777777 is borderline)
      expect(darkColorScheme.outline.toARGB32(), greaterThan(0xFF808080));

      // OutlineVariant should provide contrast (not 0xFF414141 or darker)
      expect(
        darkColorScheme.outlineVariant.toARGB32(),
        greaterThan(0xFF505050),
      );
    });

    test('should maintain dark theme brightness', () {
      expect(darkColorScheme.brightness, equals(Brightness.dark));
    });

    test('should provide adequate contrast for text', () {
      // Soft dark theme - onSurface (primary text) should be 0xFFEAEAEA
      expect(darkColorScheme.onSurface, equals(const Color(0xFFEAEAEA)));

      // OnSurfaceVariant (secondary text) should be 0xFFA0A0A0
      expect(darkColorScheme.onSurfaceVariant, equals(const Color(0xFFA0A0A0)));
    });

    test('should preserve primary and accent colors', () {
      // Primary colors should remain consistent with the app branding
      expect(darkColorScheme.primary, equals(const Color(0xFF80CBC4)));
      expect(darkColorScheme.secondary, equals(const Color(0xFFFC6E75)));
      expect(darkColorScheme.tertiary, equals(const Color(0xFFF75F67)));
    });
  });
}
