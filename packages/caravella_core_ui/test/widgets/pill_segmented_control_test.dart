import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('reports the tapped segment and exposes the selection', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PillSegmentedControl(
            labels: const ['Expenses', 'Balances', 'Statistics'],
            selectedIndex: 1,
            onChanged: (i) => tapped = i,
            expand: true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Statistics'));
    expect(tapped, 2);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Balances')),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Expenses')),
      isSemantics(isSelected: false, isButton: true, hasTapAction: true),
    );
  });
}
