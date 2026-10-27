import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/components/expense_form_component.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_state.dart';

/// Quick-add sheet (Home): no details section, a visible "More details"
/// pill opens the full page instead of the old hidden swipe-up.
void main() {
  Future<gen.AppLocalizations> pump(
    WidgetTester tester, {
    ExpenseDetails? initialExpense,
    void Function(ExpenseFormState)? onExpand,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExpenseFormComponent.legacy(
              initialExpense: initialExpense,
              participants: [ExpenseParticipant(id: 'p1', name: 'Mario')],
              categories: [ExpenseCategory(id: 'c1', name: 'Food')],
              onExpenseAdded: (_) {},
              onCategoryAdded: (_) {},
              groupId: 'g1',
              autoLocationEnabled: false,
              fullEdit: false,
              onExpand: onExpand ?? (_) {},
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

  testWidgets('the quick sheet hides the details behind More details', (
    tester,
  ) async {
    final l10n = await pump(tester);

    expect(
      find.widgetWithText(FormPill, l10n.expense_more_details),
      findsOneWidget,
    );
    expect(find.text(l10n.expense_details_section.toUpperCase()), findsNothing);
    expect(find.widgetWithText(FormPill, l10n.location), findsNothing);
    expect(find.widgetWithText(FormPill, l10n.note), findsNothing);
  });

  testWidgets('More details opens the full page with what was entered', (
    tester,
  ) async {
    ExpenseFormState? expanded;
    final l10n = await pump(tester, onExpand: (state) => expanded = state);

    await tester.tap(find.widgetWithText(FormPill, l10n.expense_more_details));
    await tester.pumpAndSettle();

    expect(expanded, isNotNull);
    expect(expanded!.paidBy?.id, 'p1');
    expect(expanded!.category?.id, 'c1');
    expect(expanded!.isExpanded, isTrue);
  });

  testWidgets('swiping up no longer expands', (tester) async {
    ExpenseFormState? expanded;
    await pump(tester, onExpand: (state) => expanded = state);

    await tester.fling(
      find.byType(ExpenseFormComponent),
      const Offset(0, -350),
      300,
    );
    await tester.pumpAndSettle();

    expect(expanded, isNull);
  });

  testWidgets('a scanned receipt shows its photo in the quick sheet', (
    tester,
  ) async {
    final l10n = await pump(
      tester,
      initialExpense: ExpenseDetails(
        id: '',
        amount: null,
        paidBy: ExpenseParticipant(id: 'p1', name: 'Mario'),
        category: ExpenseCategory(id: 'c1', name: 'Food'),
        date: DateTime(2026, 10, 20),
        attachments: const ['/nowhere/receipt.jpg'],
      ),
    );

    expect(find.text(l10n.attachments.toUpperCase()), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
    expect(
      find.widgetWithText(FormPill, l10n.expense_more_details),
      findsOneWidget,
    );
  });
}
