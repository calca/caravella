import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('SpendingWave', () {
    test('needs at least two steps with spending', () {
      expect(SpendingWave.canShow(const []), isFalse);
      expect(SpendingWave.canShow(const [10]), isFalse);
      expect(SpendingWave.canShow(const [0, 10, 0]), isFalse);
      expect(SpendingWave.canShow(const [5, 0, 10]), isTrue);
    });

    test('points span the box, highest value at the top', () {
      final painter = SpendingWavePainter(
        values: const [0, 50, 100],
        fill: Colors.grey,
        line: Colors.black,
        dot: Colors.teal,
      );
      final points = painter.pointsFor(const Size(100, 40));
      const pad = SpendingWavePainter.dotRadius + 1;
      expect(points.first.dx, pad);
      expect(points.last.dx, 100 - pad);
      expect(points.last.dy, pad); // 100 is the top
      expect(points.first.dy, 40 - pad); // 0 is the bottom
      expect(points[1].dy, closeTo(20, 0.001));
    });

    testWidgets('shows the two ends of the period', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpendingWave(
              values: [10, 0, 30],
              startLabel: '11 Oct',
              endLabel: 'Today',
            ),
          ),
        ),
      );
      expect(find.text('11 Oct'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('PhotoVeil', () {
    test('photo on top, surface under the text, stops in order', () {
      const veil = PhotoVeil(
        path: 'x.jpg',
        color: Colors.white,
        solidExtent: 100,
        fadeExtent: 100,
        topShade: true,
      );
      final g = veil.gradientFor(400);
      for (var i = 1; i < g.stops!.length; i++) {
        expect(g.stops![i], greaterThanOrEqualTo(g.stops![i - 1]));
      }
      expect(g.colors.first.a, closeTo(PhotoVeil.topShadeAlpha, 0.01));
      // The photo is untouched until the fade starts (400 - 100 - 100 px).
      final clearUntil = g.stops![g.colors.lastIndexWhere((c) => c.a == 0)];
      expect(clearUntil, closeTo(200 / 400, 0.001));
      // Solid surface from 300 px down: the text never sits on the photo.
      final solidFrom = g.stops![g.colors.indexOf(Colors.white)];
      expect(solidFrom, closeTo(300 / 400, 0.001));
      expect(g.colors.last, Colors.white);
    });

    test('a veil shorter than its parts keeps valid stops', () {
      final g = const PhotoVeil(
        path: 'x.jpg',
        color: Colors.white,
        solidExtent: 80,
      ).gradientFor(40);
      for (var i = 1; i < g.stops!.length; i++) {
        expect(g.stops![i], greaterThanOrEqualTo(g.stops![i - 1]));
      }
      expect(g.stops!.every((s) => s >= 0 && s <= 1), isTrue);
    });
  });
}
