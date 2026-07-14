import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:caravella_core_ui/map/map_bounds_utils.dart';

void main() {
  group('computeBounds', () {
    test('returns null for an empty list', () {
      expect(computeBounds([]), isNull);
    });

    test('covers all points for a normal spread', () {
      final bounds = computeBounds([
        const LatLng(45.0, 9.0),
        const LatLng(46.0, 10.0),
        const LatLng(44.5, 8.5),
      ]);

      expect(bounds, isNotNull);
      expect(bounds!.south, 44.5);
      expect(bounds.north, 46.0);
      expect(bounds.west, 8.5);
      expect(bounds.east, 10.0);
    });

    test('expands a single point into a minimum-span box', () {
      final bounds = computeBounds([const LatLng(45.0, 9.0)]);

      expect(bounds, isNotNull);
      // A single point has zero span, so both axes must be expanded.
      expect(bounds!.north, greaterThan(bounds.south));
      expect(bounds.east, greaterThan(bounds.west));
      // The point itself stays within the expanded bounds.
      expect(bounds.contains(const LatLng(45.0, 9.0)), isTrue);
    });

    test('expands points that are nearly identical', () {
      final bounds = computeBounds([
        const LatLng(45.0, 9.0),
        const LatLng(45.00001, 9.00001),
      ]);

      expect(bounds, isNotNull);
      expect(bounds!.north - bounds.south, greaterThan(0.00001));
      expect(bounds.east - bounds.west, greaterThan(0.00001));
    });

    test('does not expand a span that already exceeds the minimum', () {
      final bounds = computeBounds(
        [const LatLng(0.0, 0.0), const LatLng(1.0, 1.0)],
        minSpanDegrees: 0.002,
      );

      expect(bounds, isNotNull);
      expect(bounds!.south, 0.0);
      expect(bounds.north, 1.0);
      expect(bounds.west, 0.0);
      expect(bounds.east, 1.0);
    });

    test('respects a custom minSpanDegrees', () {
      final tight = computeBounds(
        [const LatLng(45.0, 9.0)],
        minSpanDegrees: 0.002,
      );
      final wide = computeBounds(
        [const LatLng(45.0, 9.0)],
        minSpanDegrees: 2.0,
      );

      final tightSpan = tight!.north - tight.south;
      final wideSpan = wide!.north - wide.south;
      expect(wideSpan, greaterThan(tightSpan));
    });
  });
}
