import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG contrast ratio between two opaque colors.
double _ratio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, s) in [
    ('light', lightColorScheme),
    ('dark', darkColorScheme),
  ]) {
    group('$name theme text contrast (WCAG AA 4.5:1)', () {
      final backgrounds = {
        'surface': s.surface,
        'surfaceContainer': s.surfaceContainer,
        'raisedSurface': s.raisedSurface,
      };
      final texts = {
        'onSurface': s.onSurface,
        'onSurfaceVariant': s.onSurfaceVariant,
        'outline': s.outline,
        'primary': s.primary,
        'error': s.error,
      };
      for (final MapEntry(key: fg, value: fgColor) in texts.entries) {
        for (final MapEntry(key: bg, value: bgColor) in backgrounds.entries) {
          test('$fg on $bg', () {
            expect(_ratio(fgColor, bgColor), greaterThanOrEqualTo(4.5));
          });
        }
      }
      test('on-colors on their fills', () {
        expect(_ratio(s.onPrimary, s.primary), greaterThanOrEqualTo(4.5));
        expect(
          _ratio(s.onPrimaryContainer, s.primaryContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(_ratio(s.onError, s.error), greaterThanOrEqualTo(4.5));
        expect(_ratio(s.onSuccess, s.success), greaterThanOrEqualTo(4.5));
        expect(_ratio(s.onWarning, s.warning), greaterThanOrEqualTo(4.5));
      });
      test('status icons and dots (3:1, WCAG 1.4.11)', () {
        for (final bg in backgrounds.values) {
          expect(_ratio(s.success, bg), greaterThanOrEqualTo(3));
          expect(_ratio(s.warning, bg), greaterThanOrEqualTo(3));
        }
      });
    });
  }
}
