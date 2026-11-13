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
}
