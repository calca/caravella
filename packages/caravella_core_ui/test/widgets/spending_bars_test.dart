import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    List<double> values, {
    double width = 326,
    double textScale = 1,
    String Function(double)? amountLabel,
  }) => tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: SpendingBars(
                values: values,
                semanticLabel: 'Spending',
                amountLabel: amountLabel,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  double barHeight(WidgetTester tester, int i) =>
      tester.getSize(find.byKey(SpendingBars.barKey(i))).height;

  String euros(double v) => '${v.toStringAsFixed(0)} €';

  testWidgets('a single day draws a bar as tall as the chart', (tester) async {
    await pump(tester, [67]);

    expect(barHeight(tester, 0), 96);
    expect(tester.getSize(find.byKey(SpendingBars.barKey(0))).width, 44);
  });

  testWidgets('equal amounts are equally tall, not flat', (tester) async {
    await pump(tester, [30, 30, 30]);

    expect(barHeight(tester, 0), 96);
    expect(barHeight(tester, 2), 96);
  });

  testWidgets('heights start from zero', (tester) async {
    await pump(tester, [100, 110]);

    expect(
      barHeight(tester, 0) / barHeight(tester, 1),
      closeTo(100 / 110, 0.01),
    );
  });

  testWidgets('days without spending are a short mark without an amount', (
    tester,
  ) async {
    await pump(tester, [20, 0, 40], amountLabel: euros);

    expect(barHeight(tester, 1), 3);
    expect(find.text('20 €'), findsOneWidget);
    expect(find.text('0 €'), findsNothing);
  });

  testWidgets('amounts show up to seven bars', (tester) async {
    await pump(tester, List.filled(7, 10), amountLabel: euros);
    expect(find.text('10 €'), findsNWidgets(7));

    await pump(tester, List.filled(8, 10), amountLabel: euros);
    expect(find.text('10 €'), findsNothing);
  });

  testWidgets('a tiny amount stays visible next to a huge one', (tester) async {
    await pump(tester, [1, 100000]);

    expect(barHeight(tester, 0), 6);
  });

  testWidgets('draws nothing without spending', (tester) async {
    await pump(tester, [0, 0]);

    expect(find.byKey(SpendingBars.barKey(0)), findsNothing);
  });

  testWidgets('fits many bars, long amounts and large text', (tester) async {
    await pump(tester, List.filled(120, 10));
    expect(tester.takeException(), isNull);

    await pump(
      tester,
      [1234567, 2345678, 3456789, 1, 2, 3, 4],
      width: 200,
      textScale: 3,
      amountLabel: euros,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reads as one image to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, [10, 20], amountLabel: euros);

    expect(find.bySemanticsLabel('Spending'), findsOneWidget);
    handle.dispose();
  });
}
