import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool showBadge}) =>
      tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: WeeklyExpenseChart(
                dailyTotals: const [0, 10, 5, 0, 0, 20, 0],
                theme: Theme.of(context),
                badgeText: 'W',
                semanticLabel: 'Weekly expenses',
                showBadge: showBadge,
                height: 96,
              ),
            ),
          ),
        ),
      );

  testWidgets('shows the letter badge by default', (tester) async {
    await pump(tester, showBadge: true);
    expect(find.byType(ChartBadge), findsOneWidget);
  });

  testWidgets('without badge it keeps a spoken label', (tester) async {
    await pump(tester, showBadge: false);
    expect(find.byType(ChartBadge), findsNothing);
    expect(find.bySemanticsLabel('Weekly expenses'), findsOneWidget);
  });
}
