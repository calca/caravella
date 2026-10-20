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
    test('scrim behind the text, surface at the bottom, stops in order', () {
      const veil = PhotoVeil(
        path: 'x.jpg',
        color: Colors.white,
        textExtent: 100,
        rampExtent: 50,
        solidExtent: 50,
        topShade: true,
      );
      final g = veil.gradientFor(400);
      for (var i = 1; i < g.stops!.length; i++) {
        expect(g.stops![i], greaterThanOrEqualTo(g.stops![i - 1]));
      }
      expect(g.colors.first.a, closeTo(PhotoVeil.topShadeAlpha, 0.01));
      expect(g.colors.last, Colors.white);
      // Full scrim from 250 px (400 - 50 solid - 100 text).
      final scrimAt =
          g.stops![g.colors.indexWhere(
            (c) => (c.a - PhotoVeil.scrimAlpha).abs() < 0.01,
          )];
      expect(scrimAt, closeTo(250 / 400, 0.001));
    });

    test('a veil shorter than its parts keeps valid stops', () {
      final g = const PhotoVeil(
        path: 'x.jpg',
        color: Colors.white,
      ).gradientFor(40);
      for (var i = 1; i < g.stops!.length; i++) {
        expect(g.stops![i], greaterThanOrEqualTo(g.stops![i - 1]));
      }
      expect(g.stops!.every((s) => s >= 0 && s <= 1), isTrue);
    });
  });
}
