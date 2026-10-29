import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The shared field for adding a name in place (group creation, pickers,
/// group settings): ✓ greyed out while empty, Enter or ✓ confirms, a
/// refused name stays, and with keepOpen the field is ready for the next.
void main() {
  Future<List<String>> pump(
    WidgetTester tester, {
    bool keepOpen = false,
    Set<String> refuse = const {},
    VoidCallback? onCancel,
  }) async {
    final taken = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: CaravellaThemes.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: InlineEntryField(
              hintText: 'A friend’s name',
              commitTooltip: 'Add',
              cancelTooltip: 'Cancel',
              keepOpen: keepOpen,
              onCommit: (value) {
                if (refuse.contains(value)) return false;
                taken.add(value);
                return true;
              },
              onCancel: onCancel ?? () {},
            ),
          ),
        ),
      ),
    );
    return taken;
  }

  IconButton check(WidgetTester tester) => tester.widget<IconButton>(
    find.descendant(
      of: find.byType(FieldActionButton),
      matching: find.byType(IconButton),
    ),
  );

  testWidgets('✓ is greyed out until there is a name', (tester) async {
    await pump(tester);
    expect(check(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(check(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Marco');
    await tester.pump();
    expect(check(tester).onPressed, isNotNull);
  });

  testWidgets('with keepOpen a taken name empties the field, still focused', (
    tester,
  ) async {
    final taken = await pump(tester, keepOpen: true);
    await tester.enterText(find.byType(TextField), '  Marco ');
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pump();
    expect(taken, ['Marco']);
    expect(find.text('Marco'), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);

    // Enter adds too.
    await tester.enterText(find.byType(TextField), 'Giulia');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(taken, ['Marco', 'Giulia']);
  });

  testWidgets('a refused name stays in the field', (tester) async {
    final taken = await pump(tester, keepOpen: true, refuse: {'Anna'});
    await tester.enterText(find.byType(TextField), 'Anna');
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pump();
    expect(taken, isEmpty);
    expect(find.text('Anna'), findsOneWidget);
  });

  testWidgets('× cancels', (tester) async {
    var cancelled = 0;
    await pump(tester, onCancel: () => cancelled++);
    await tester.tap(find.byTooltip('Cancel'));
    expect(cancelled, 1);
  });
}
