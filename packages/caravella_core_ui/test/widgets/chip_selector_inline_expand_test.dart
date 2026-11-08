import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// In the quick-add sheet ([ChipSelectorRow.singleLine]) "+N" expands the
/// row in place: no second sheet, so an open keyboard is never touched.
void main() {
  final items = ['Food', 'Transport', 'Accommodation', 'Groceries', 'Fun'];

  String? picked;
  final added = <String>[];
  late FocusNode amountFocus;

  Future<void> pump(
    WidgetTester tester, {
    List<String>? list,
    Future<void> Function(String)? onAdd,
    double width = 300,
  }) async {
    picked = null;
    added.clear();
    amountFocus = FocusNode();
    addTearDown(amountFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                TextField(focusNode: amountFocus),
                SizedBox(
                  width: width,
                  child: ChipSelectorRow<String>(
                    items: list ?? items,
                    selected: 'Food',
                    itemLabel: (s) => s,
                    onSelected: (v) => picked = v,
                    onAddItemInline:
                        onAdd ??
                        (name) async {
                          added.add(name);
                        },
                    addItemHint: 'Name',
                    addLabel: 'Add',
                    cancelLabel: 'Cancel',
                    addCategoryLabel: 'Add category',
                    alreadyExistsMessage: 'Already exists',
                    sheetTitle: 'Category',
                    singleLine: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    amountFocus.requestFocus();
    await tester.pump();
  }

  Finder more() => find.textContaining(RegExp(r'^\+\d+$'));

  Future<void> openAddField(WidgetTester tester) async {
    await tester.tap(more());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
  }

  testWidgets('+N expands in place: no sheet, focus kept, all items shown', (
    tester,
  ) async {
    await pump(tester);
    final focusBefore = FocusManager.instance.primaryFocus;
    expect(focusBefore, amountFocus);
    expect(find.text('Fun'), findsNothing);

    await tester.tap(more());
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(ModalBottomSheetRoute), findsNothing);
    for (final i in items) {
      expect(find.text(i), findsOneWidget);
    }
    expect(find.text('Add category'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus, focusBefore);
  });

  testWidgets('selecting collapses back to one line', (tester) async {
    await pump(tester);
    await tester.tap(more());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fun'));
    await tester.pumpAndSettle();

    expect(picked, 'Fun');
    expect(more(), findsOneWidget);
    expect(find.text('Add category'), findsNothing);
    expect(FocusManager.instance.primaryFocus, amountFocus);
  });

  testWidgets('inline add: field takes focus, add calls back and collapses', (
    tester,
  ) async {
    await pump(tester);
    await openAddField(tester);

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2));
    final focused = FocusManager.instance.primaryFocus!;
    expect(focused, isNot(amountFocus));
    expect(
      focused.context!.findAncestorWidgetOfExactType<TextField>(),
      isNotNull,
    );

    await tester.enterText(find.byType(TextField).last, 'Gifts');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(added, ['Gifts']);
    expect(FocusManager.instance.primaryFocus, amountFocus);
    expect(find.byType(TextField), findsOneWidget);
    expect(more(), findsOneWidget);
  });

  testWidgets('duplicate name shows the message and does not add', (
    tester,
  ) async {
    await pump(tester);
    await openAddField(tester);
    await tester.enterText(find.byType(TextField).last, 'food');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Already exists'), findsOneWidget);
    expect(added, isEmpty);
  });

  testWidgets('cancel closes the field and keeps the list open', (
    tester,
  ) async {
    await pump(tester);
    await openAddField(tester);
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(FocusManager.instance.primaryFocus, amountFocus);
    expect(find.text('Add category'), findsOneWidget);
  });

  testWidgets('a failing add keeps the field open', (tester) async {
    await pump(tester, onAdd: (_) async => throw Exception('boom'));
    await openAddField(tester);
    await tester.enterText(find.byType(TextField).last, 'Gifts');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('many items do not overflow and scroll', (tester) async {
    final many = [for (var i = 0; i < 30; i++) 'Category number $i'];
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pump(tester, list: many, width: 360);
    await tester.tap(more());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final row = find.descendant(
      of: find.byType(ChipSelectorRow<String>),
      matching: find.byType(SingleChildScrollView),
    );
    expect(
      tester.getSize(row).height,
      lessThanOrEqualTo(ChipSelectorRow.expandedMaxHeight),
    );
  });
}
