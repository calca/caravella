import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Whatever is selected, the overflow pill stays and opens the full list.
void main() {
  for (final count in [6, 7, 8]) {
    for (var pick = 0; pick < count; pick++) {
      testWidgets('$count items, item ${pick + 1} selected', (tester) async {
        final items = [for (var i = 1; i <= count; i++) 'Item $i'];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChipSelectorRow<String>(
                items: items,
                selected: items[pick],
                itemLabel: (s) => s,
                onSelected: (_) {},
                sheetTitle: 'All items',
                onAddItemInline: (_) async {},
              ),
            ),
          ),
        );
        final more = find.bySemanticsLabel('All items');
        expect(more, findsOneWidget, reason: 'overflow pill');
        await tester.tap(more);
        await tester.pumpAndSettle();
        expect(find.text('Item $count'), findsWidgets, reason: 'sheet');
      });
    }
  }
}
