import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('search bar: query, clear and filters count', (tester) async {
    final controller = TextEditingController();
    final changes = <String>[];
    var filters = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchTopBar(
            controller: controller,
            hintText: 'Search groups',
            onChanged: changes.add,
            onFilters: () => filters++,
            activeFilters: 2,
            filtersTooltip: 'Filters',
            clearTooltip: 'Clear',
          ),
        ),
      ),
    );
    expect(find.text('Search groups'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ski');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(changes, ['ski', '']);
    expect(controller.text, isEmpty);

    await tester.tap(find.byTooltip('Filters (2)'));
    expect(filters, 1);
    expect(find.text('2'), findsOneWidget); // badge
  });

  testWidgets('pills: selection and removal', (tester) async {
    var removed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PillSection(
            label: 'Paid by',
            pills: [
              const FilterPill(label: 'Anna'),
              FilterPill(
                label: 'Marco',
                selected: true,
                onRemove: () => removed = true,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('PAID BY'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.tap(find.text('Marco'));
    expect(removed, isTrue);
    expect(
      tester.getSemantics(find.text('Marco')),
      isSemantics(isSelected: true, isButton: true),
    );
  });

  testWidgets('highlights the whole match, not scattered letters', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HighlightedText(text: 'Norway Road Trip', query: 'road'),
        ),
      ),
    );
    final rich = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
    final parts = rich.children!.map((c) => (c as TextSpan).text).toList();
    expect(parts, ['Norway ', 'Road', ' Trip']);
  });
}
