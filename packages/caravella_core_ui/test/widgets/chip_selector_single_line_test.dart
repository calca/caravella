import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The quick-add sheet keeps paid-by and category on one line: what fits,
/// then "+N" on the same line; the current choice always shows.
void main() {
  const items = [
    'Food',
    'Transport',
    'Accommodation',
    'Groceries',
    'Activities',
  ];

  Future<void> pump(
    WidgetTester tester, {
    String? selected,
    double width = 300,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: ChipSelectorRow<String>(
              items: items,
              selected: selected,
              itemLabel: (s) => s,
              onSelected: (_) {},
              onAddItemInline: (_) async {},
              sheetTitle: 'Category',
              singleLine: true,
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('shows what fits and +N on the same line', (tester) async {
    await pump(tester, selected: 'Food');
    final more = find.textContaining(RegExp(r'^\+\d$'));
    expect(more, findsOneWidget);
    final shown = items.where((i) => find.text(i).evaluate().isNotEmpty);
    expect(shown.length, lessThan(items.length));
    expect(more.evaluate().single.widget, isA<Text>());
    expect((tester.widget<Text>(more)).data, '+${items.length - shown.length}');
    // One line: every pill has the same vertical center.
    final y = tester.getCenter(find.text('Food')).dy;
    expect(tester.getCenter(more).dy, closeTo(y, 0.5));
  });

  testWidgets('a hidden choice takes the last visible place', (tester) async {
    await pump(tester, selected: 'Activities');
    expect(find.text('Activities'), findsOneWidget);
  });

  testWidgets('everything fits: no +N, the add pill instead', (tester) async {
    await tester.binding.setSurfaceSize(const Size(2400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pump(tester, width: 2000);
    for (final i in items) {
      expect(find.text(i), findsOneWidget);
    }
    expect(find.textContaining(RegExp(r'^\+\d$')), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
