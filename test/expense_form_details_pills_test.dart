import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/components/expense_form_component.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_controller.dart';
import 'package:io_caravella_egm/manager/expense/widgets/note_input_widget.dart';

/// Expense form, option C: who paid and category as pills under their
/// labels, then date / place / attachments / note as "Details" pills.
void main() {
  Future<gen.AppLocalizations> pumpForm(
    WidgetTester tester, {
    ExpenseDetails? initialExpense,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExpenseFormComponent.legacy(
              initialExpense: initialExpense,
              participants: [ExpenseParticipant(id: 'p1', name: 'Anna')],
              categories: [ExpenseCategory(id: 'c1', name: 'Food')],
              onExpenseAdded: (_) {},
              onCategoryAdded: (_) {},
              groupId: 'g1',
              autoLocationEnabled: false,
              fullEdit: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return gen.AppLocalizations.of(
      tester.element(find.byType(ExpenseFormComponent)),
    );
  }

  FormPill pill(WidgetTester tester, String label) =>
      tester.widget<FormPill>(find.widgetWithText(FormPill, label));

  testWidgets('who paid and category are pills under their labels', (
    tester,
  ) async {
    final l10n = await pumpForm(tester);

    expect(find.text(l10n.paid_by.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.category.toUpperCase()), findsOneWidget);
    expect(pill(tester, 'Anna').style, FormPillStyle.selected);
    expect(pill(tester, 'Food').style, FormPillStyle.selected);
  });

  testWidgets('a new expense shows the details as pills to add', (
    tester,
  ) async {
    final l10n = await pumpForm(tester);

    expect(
      find.text(l10n.expense_details_section.toUpperCase()),
      findsOneWidget,
    );
    expect(pill(tester, l10n.today).style, FormPillStyle.normal);
    expect(pill(tester, l10n.location).style, FormPillStyle.add);
    expect(pill(tester, l10n.attachments).style, FormPillStyle.add);
    expect(pill(tester, l10n.note).style, FormPillStyle.add);
    expect(find.byType(NoteInputWidget), findsNothing);
  });

  testWidgets('tapping the note pill opens the note field', (tester) async {
    final l10n = await pumpForm(tester);

    await tester.tap(find.widgetWithText(FormPill, l10n.note));
    await tester.pumpAndSettle();

    expect(find.byType(NoteInputWidget), findsOneWidget);
    expect(find.widgetWithText(FormPill, l10n.note), findsNothing);
  });

  testWidgets('an existing note shows the field right away', (tester) async {
    await pumpForm(
      tester,
      initialExpense: ExpenseDetails(
        id: 'e1',
        name: 'Dinner',
        amount: 54.5,
        paidBy: ExpenseParticipant(id: 'p1', name: 'Anna'),
        category: ExpenseCategory(id: 'c1', name: 'Food'),
        date: DateTime(2026, 10, 17),
        note: 'Fish soup',
      ),
    );

    expect(find.byType(NoteInputWidget), findsOneWidget);
    expect(find.text('Fish soup'), findsOneWidget);
    expect(find.text('54.50'), findsOneWidget);
  });

  test('amounts show two decimals unless whole', () {
    expect(ExpenseFormController.formatAmountForInput(54.5), '54.50');
    expect(ExpenseFormController.formatAmountForInput(12), '12');
    expect(ExpenseFormController.formatAmountForInput(3.14159), '3.14');
  });
}
