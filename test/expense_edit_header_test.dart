import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/pages/expense_form_page.dart';
import 'package:material_ui/material_ui.dart';

/// The expense page's header when editing: the expense is the title, the
/// amount has its currency after it, who paid and each one's share are
/// under it, share and delete are in the ⋯ menu, and Save waits for a
/// change.
void main() {
  final anna = ExpenseParticipant(id: 'a', name: 'Anna');
  final marco = ExpenseParticipant(id: 'm', name: 'Marco');
  final food = ExpenseCategory(id: 'f', name: 'Food');
  final expense = ExpenseDetails(
    id: 'e1',
    name: 'Pizza',
    amount: 42,
    paidBy: anna,
    category: food,
    date: DateTime(2026, 11, 17),
  );
  final group = ExpenseGroup(
    id: 'g1',
    title: 'Norway',
    expenses: [expense],
    participants: [anna, marco],
    categories: [food],
    currency: '€',
  );

  Future<void> open(WidgetTester tester, {VoidCallback? onDelete}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        home: ExpenseFormPage(
          group: group,
          initialExpense: expense,
          onExpenseSaved: (_) {},
          onCategoryAdded: (_) {},
          onDelete: onDelete,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the expense is the title, no "Edit expense" on screen', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    expect(find.text('Edit expense'), findsNothing);
    // Still the page's heading for screen readers.
    expect(find.bySemanticsLabel('Edit expense'), findsOneWidget);
    expect(find.text('Norway · Tue, Nov 17'), findsOneWidget);
    expect(find.text('Pizza'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('who paid and each one\'s share are under the amount', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Paid by Anna · 21.00 € per person'), findsOneWidget);
    // The amount, with its currency after it.
    final amount = tester.getRect(
      find.byWidgetPredicate(
        (w) => w is EditableText && w.controller.text == '42',
      ),
    );
    final currency = tester.getRect(find.text('€'));
    expect(currency.left, greaterThan(amount.right));
  });

  testWidgets('share and delete are in the ⋯ menu', (tester) async {
    var deleted = false;
    await open(tester, onDelete: () => deleted = true);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    await tester.tap(find.byType(RoundMenuButton));
    await tester.pumpAndSettle();
    expect(find.text('Share'), findsOneWidget);
    await tester.tap(find.text('Delete expense'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });

  testWidgets('Save waits for a change', (tester) async {
    await open(tester);
    FilledButton save() => tester.widget<FilledButton>(
      find.ancestor(of: find.text('Save'), matching: find.byType(FilledButton)),
    );
    expect(save().onPressed, isNull);
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is EditableText && w.controller.text == 'Pizza',
      ),
      'Pizza and beer',
    );
    await tester.pumpAndSettle();
    expect(save().onPressed, isNotNull);
  });
}
