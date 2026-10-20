import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG 2.x contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Every surface text can sit on.
List<Color> _surfaces(ColorScheme s) => [
  s.surface,
  s.surfaceContainerLowest,
  s.surfaceContainerLow,
  s.surfaceContainer,
  s.surfaceContainerHigh,
  s.surfaceContainerHighest,
];

void main() {
  for (final entry in {
    'light': lightColorScheme,
    'dark': darkColorScheme,
  }.entries) {
    final scheme = entry.value;

    group('${entry.key} theme contrast (WCAG AA)', () {
      test('primary, outline and onSurface are readable text on surfaces', () {
        for (final surface in _surfaces(scheme)) {
          for (final text in [
            scheme.onSurface,
            scheme.primary,
            scheme.outline,
          ]) {
            expect(
              _contrast(text, surface),
              greaterThanOrEqualTo(4.5),
              reason: '$text on $surface',
            );
          }
        }
      });

      test('on-colors are readable on their fills', () {
        final pairs = {
          scheme.primary: scheme.onPrimary,
          scheme.secondary: scheme.onSecondary,
          scheme.tertiary: scheme.onTertiary,
          scheme.error: scheme.onError,
        };
        pairs.forEach((fill, on) {
          expect(
            _contrast(on, fill),
            greaterThanOrEqualTo(4.5),
            reason: '$on on $fill',
          );
        });
      });

      test('text field underline meets non-text contrast (3:1)', () {
        for (final surface in _surfaces(scheme)) {
          expect(_contrast(scheme.outline, surface), greaterThanOrEqualTo(3));
        }
      });

      test('on-photo text stays readable over a white or black photo', () {
        const alpha = GroupBackgroundUtils.imageTextScrimAlpha;
        for (final photo in [Colors.white, Colors.black]) {
          final veiled = Color.alphaBlend(
            scheme.surface.withValues(alpha: alpha),
            photo,
          );
          expect(
            _contrast(scheme.onSurface, veiled),
            greaterThanOrEqualTo(4.5),
            reason: 'onSurface over $photo',
          );
        }
      });

      test('white text stays readable on the photo scrim', () {
        // PhotoVeil: title, dates and amounts written on the photo are white
        // over a black scrim, whatever the photo underneath (secondary lines
        // too: no faded white on a photo).
        for (final photo in [Colors.white, Colors.black, scheme.primary]) {
          final scrimmed = Color.alphaBlend(
            Colors.black.withValues(alpha: PhotoVeil.scrimAlpha),
            photo,
          );
          expect(
            _contrast(PhotoVeil.onPhoto, scrimmed),
            greaterThanOrEqualTo(4.5),
            reason: 'on-photo text over $photo',
          );
        }
      });
    });
  }
}
