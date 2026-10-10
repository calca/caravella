import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/pages/expense_form_page.dart';

void main() {
  final participants = [
    ExpenseParticipant(id: 'p1', name: 'Mario'),
    ExpenseParticipant(id: 'p2', name: 'Luigi'),
  ];
  final categories = [
    ExpenseCategory(id: 'c1', name: 'Food'),
    ExpenseCategory(id: 'c2', name: 'Fuel'),
  ];
  final expense = ExpenseDetails(
    id: 'e1',
    name: 'Pizza',
    amount: 12.5,
    paidBy: participants[1],
    category: categories[1],
    date: DateTime(2026, 9, 1),
    note: 'Dinner',
    location: ExpenseLocation(latitude: 45.0, longitude: 9.0, name: 'Milano'),
  );
  final group = ExpenseGroup(
    id: 'g1',
    title: 'Trip',
    expenses: [expense],
    participants: participants,
    categories: categories,
    currency: '€',
    autoLocationEnabled: true,
  );

  Future<gen.AppLocalizations> openEditPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExpenseFormPage(
                      group: group,
                      initialExpense: expense,
                      onExpenseSaved: (_) {},
                      onCategoryAdded: (_) {},
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return gen.AppLocalizations.of(
      tester.element(find.byType(ExpenseFormPage)),
    );
  }

  Future<void> goBack(WidgetTester tester) async {
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'opening an existing expense and going back without edits does not ask '
    'to discard changes',
    (tester) async {
      final l10n = await openEditPage(tester);
      await goBack(tester);

      expect(find.text(l10n.discard_changes_title), findsNothing);
      expect(find.byType(ExpenseFormPage), findsNothing);
    },
  );

  testWidgets(
    'IME editing-value updates that keep the same text (cursor/composing '
    'changes) do not count as edits',
    (tester) async {
      final l10n = await openEditPage(tester);

      final amountField = find.byWidgetPredicate(
        (w) => w is EditableText && w.controller.text == '12.5',
      );
      await tester.showKeyboard(amountField);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '12.5',
          selection: TextSelection.collapsed(offset: 0),
          composing: TextRange(start: 0, end: 4),
        ),
      );
      await tester.pumpAndSettle();
      await goBack(tester);

      expect(find.text(l10n.discard_changes_title), findsNothing);
      expect(find.byType(ExpenseFormPage), findsNothing);
    },
  );

  testWidgets('a real edit still asks to discard changes', (tester) async {
    final l10n = await openEditPage(tester);

    final amountField = find.byWidgetPredicate(
      (w) => w is EditableText && w.controller.text == '12.5',
    );
    await tester.enterText(amountField, '13');
    await tester.pumpAndSettle();
    await goBack(tester);

    expect(find.text(l10n.discard_changes_title), findsOneWidget);
    expect(find.byType(ExpenseFormPage), findsOneWidget);
  });
}
