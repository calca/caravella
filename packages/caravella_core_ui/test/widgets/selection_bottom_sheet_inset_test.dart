import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// In a long list the "Add …" pill at the end stays clear of the system
/// navigation bar (the sheet is edge to edge).
void main() {
  testWidgets('add pill ends above the navigation bar', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    // A 48 dp gesture/navigation bar.
    tester.view.padding = const FakeViewPadding(bottom: 144);
    tester.view.viewPadding = const FakeViewPadding(bottom: 144);
    addTearDown(tester.view.reset);

    final items = [for (var i = 1; i <= 15; i++) 'Person $i'];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showSelectionBottomSheet<String>(
              context: context,
              items: items,
              selected: items.first,
              itemLabel: (s) => s,
              sheetTitle: 'Participants',
              onAddItemInline: (_) async {},
              addCategoryLabel: 'Add participant',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Scroll the list to its end.
    final list = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(ListView),
    );
    await tester.drag(list, const Offset(0, -3000));
    await tester.pumpAndSettle();
    final add = find.widgetWithText(FormPill, 'Add participant');
    expect(add, findsOneWidget);

    final screen = tester.view.physicalSize.height / 3;
    expect(tester.getRect(add).bottom, lessThanOrEqualTo(screen - 48));
  });
}
