import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/themes/caravella_themes.dart';

void main() {
  group('Dark Theme Tests', () {
    late ColorScheme darkColorScheme;

    setUp(() {
      darkColorScheme = CaravellaThemes.dark.colorScheme;
    });

    test('should have appropriate surface colors for readability', () {
      // Surface should not be extremely dark (0xFF121212 or darker)
      // A good dark theme surface should be lighter than 0xFF1A1A1A for readability
      expect(darkColorScheme.surface.value, greaterThan(0xFF1A1A1A));
      
      // SurfaceDim should not be extremely dark (0xFF060606 or darker) 
      expect(darkColorScheme.surfaceDim.value, greaterThan(0xFF0F0F0F));
      
      // SurfaceContainerLowest should provide some contrast (not 0xFF010101)
      expect(darkColorScheme.surfaceContainerLowest.value, greaterThan(0xFF0A0A0A));
    });

    test('should maintain proper surface container hierarchy', () {
      // Surface containers should have progressive lightness for elevation
      expect(darkColorScheme.surfaceContainerLowest.value, 
             lessThan(darkColorScheme.surfaceContainerLow.value));
      expect(darkColorScheme.surfaceContainerLow.value,
             lessThan(darkColorScheme.surfaceContainer.value));
      expect(darkColorScheme.surfaceContainer.value,
             lessThan(darkColorScheme.surfaceContainerHigh.value));
      expect(darkColorScheme.surfaceContainerHigh.value,
             lessThan(darkColorScheme.surfaceContainerHighest.value));
    });

    test('should have visible outline colors', () {
      // Outline should not be too dark (0xFF777777 is borderline)
      expect(darkColorScheme.outline.value, greaterThan(0xFF808080));
      
      // OutlineVariant should provide contrast (not 0xFF414141 or darker)
      expect(darkColorScheme.outlineVariant.value, greaterThan(0xFF505050));
    });

    test('should maintain dark theme brightness', () {
      expect(darkColorScheme.brightness, equals(Brightness.dark));
    });

    test('should provide adequate contrast for text', () {
      // OnSurface should remain white for good contrast
      expect(darkColorScheme.onSurface, equals(const Color(0xFFFFFFFF)));
      
      // OnSurfaceVariant should be visible but not pure white
      expect(darkColorScheme.onSurfaceVariant.value, greaterThan(0xFFB0B0B0));
    });

    test('should preserve primary and accent colors', () {
      // Primary colors should remain consistent with the app branding
      expect(darkColorScheme.primary, equals(const Color(0xFF669DB3)));
      expect(darkColorScheme.secondary, equals(const Color(0xFFFC6E75)));
      expect(darkColorScheme.tertiary, equals(const Color(0xFFF75F67)));
    });
  });
}