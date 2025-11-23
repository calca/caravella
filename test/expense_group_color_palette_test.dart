import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseGroupColorPalette', () {
    test('paletteSize is 12', () {
      expect(ExpenseGroupColorPalette.paletteSize, equals(12));
    });

    test('getPaletteColors returns correct number of colors', () {
      const lightScheme = ColorScheme.light();
      final colors = ExpenseGroupColorPalette.getPaletteColors(lightScheme);
      expect(colors.length, equals(ExpenseGroupColorPalette.paletteSize));
    });

    test('resolveColor returns null for invalid indices', () {
      const lightScheme = ColorScheme.light();
      expect(ExpenseGroupColorPalette.resolveColor(null, lightScheme), isNull);
      expect(ExpenseGroupColorPalette.resolveColor(-1, lightScheme), isNull);
      expect(ExpenseGroupColorPalette.resolveColor(12, lightScheme), isNull);
      expect(ExpenseGroupColorPalette.resolveColor(100, lightScheme), isNull);
    });

    test('resolveColor returns color for valid palette indices', () {
      const lightScheme = ColorScheme.light();
      for (int i = 0; i < ExpenseGroupColorPalette.paletteSize; i++) {
        final color = ExpenseGroupColorPalette.resolveColor(i, lightScheme);
        expect(color, isNotNull);
        expect(color, isA<Color>());
      }
    });

    test('resolveColor returns theme-specific colors', () {
      const lightScheme = ColorScheme.light();
      const darkScheme = ColorScheme.dark();

      // Index 0 should map to primary color
      final lightPrimary = ExpenseGroupColorPalette.resolveColor(
        0,
        lightScheme,
      );
      final darkPrimary = ExpenseGroupColorPalette.resolveColor(0, darkScheme);

      expect(lightPrimary, equals(lightScheme.primary));
      expect(darkPrimary, equals(darkScheme.primary));
      // Light and dark primaries should be different (for default schemes)
      expect(lightPrimary, isNot(equals(darkPrimary)));
    });

    test('isLegacyColorValue detects palette indices vs ARGB values', () {
      // Palette indices (0-11) should not be legacy
      for (int i = 0; i < ExpenseGroupColorPalette.paletteSize; i++) {
        expect(
          ExpenseGroupColorPalette.isLegacyColorValue(i),
          isFalse,
          reason: 'Index $i should not be legacy',
        );
      }

      // ARGB color values should be legacy
      expect(
        ExpenseGroupColorPalette.isLegacyColorValue(0xFF009688),
        isTrue,
        reason: 'ARGB value should be legacy',
      );
      expect(
        ExpenseGroupColorPalette.isLegacyColorValue(0xFFE57373),
        isTrue,
        reason: 'ARGB value should be legacy',
      );

      // null should not be legacy
      expect(ExpenseGroupColorPalette.isLegacyColorValue(null), isFalse);
    });

    test('findColorIndex returns correct index for exact matches', () {
      const lightScheme = ColorScheme.light();
      final colors = ExpenseGroupColorPalette.getPaletteColors(lightScheme);

      for (int i = 0; i < colors.length; i++) {
        final argb = colors[i].value;
        final foundIndex = ExpenseGroupColorPalette.findColorIndex(
          argb,
          lightScheme,
        );

        // findColorIndex returns the first matching index when there are duplicates
        // So we verify that the color at the found index matches the original color
        expect(foundIndex, isNotNull, reason: 'Should find a matching color');
        expect(
          colors[foundIndex!].value,
          equals(argb),
          reason: 'Color at found index should match the searched color',
        );
        expect(
          foundIndex,
          lessThanOrEqualTo(i),
          reason:
              'Found index should be the first occurrence (at or before current index)',
        );
      }
    });

    test('findColorIndex returns null for non-palette colors', () {
      const lightScheme = ColorScheme.light();
      // Use a color that's unlikely to be in the palette
      const customColor = 0xFF123456;
      final foundIndex = ExpenseGroupColorPalette.findColorIndex(
        customColor,
        lightScheme,
      );
      expect(foundIndex, isNull);
    });

    test('migrateLegacyColor finds closest match', () {
      const lightScheme = ColorScheme.light();
      // Try to migrate a teal color (should match primary in default theme)
      const tealColor = 0xFF009688;
      final migratedIndex = ExpenseGroupColorPalette.migrateLegacyColor(
        tealColor,
        lightScheme,
      );
      expect(migratedIndex, isNotNull);
      expect(migratedIndex, greaterThanOrEqualTo(0));
      expect(migratedIndex, lessThan(ExpenseGroupColorPalette.paletteSize));
    });

    test('palette colors are consistent across calls', () {
      const lightScheme = ColorScheme.light();
      final colors1 = ExpenseGroupColorPalette.getPaletteColors(lightScheme);
      final colors2 = ExpenseGroupColorPalette.getPaletteColors(lightScheme);

      expect(colors1.length, equals(colors2.length));
      for (int i = 0; i < colors1.length; i++) {
        expect(colors1[i], equals(colors2[i]));
      }
    });
  });
}
