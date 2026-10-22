import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/pages/section_swipe.dart';

void main() {
  group('sectionAfterSwipe', () {
    int? swipe(
      int current,
      double distance,
      double velocity, {
      bool rtl = false,
    }) => sectionAfterSwipe(
      current: current,
      count: 3,
      distance: distance,
      velocity: velocity,
      rtl: rtl,
    );

    test('a swipe to the left opens the next section', () {
      expect(swipe(0, -120, 0), 1);
      expect(swipe(1, -20, -900), 2);
    });

    test('a swipe to the right opens the previous section', () {
      expect(swipe(2, 120, 0), 1);
      expect(swipe(1, 10, 900), 0);
    });

    test('a short, slow drag stays', () {
      expect(swipe(1, -40, -100), isNull);
    });

    test('no section past the first or the last', () {
      expect(swipe(0, 200, 0), isNull);
      expect(swipe(2, -200, 0), isNull);
    });

    test('directions flip in right-to-left layouts', () {
      expect(swipe(0, 120, 0, rtl: true), 1);
      expect(swipe(1, -120, 0, rtl: true), 0);
    });
  });
}
