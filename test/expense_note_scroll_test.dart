import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/widgets/expense_form_actions_widget.dart';
import 'package:io_caravella_egm/manager/expense/pages/expense_form_page.dart';
import 'package:io_caravella_egm/manager/expense/widgets/note_input_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Tapping the note on the expense page showed only its first line: the
/// page scrolled just enough for the cursor, and the rest of the field (four
/// lines at least) stayed under the Save bar, which rises with the keyboard.
/// The whole note now scrolls above the bar.
void main() {
  final anna = ExpenseParticipant(id: 'p1', name: 'Anna');
  final food = ExpenseCategory(id: 'c1', name: 'Food');
  final expense = ExpenseDetails(
    id: 'e1',
    name: 'Pizza',
    amount: 12.5,
    paidBy: anna,
    category: food,
    date: DateTime(2026, 9, 1),
    note: 'Dinner',
  );
  final group = ExpenseGroup(
    id: 'g1',
    title: 'Trip',
    expenses: [expense],
    participants: [anna],
    categories: [food],
    currency: '€',
  );

  testWidgets('the whole note shows above the keyboard and the Save bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

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
        ),
      ),
    );
    await tester.pumpAndSettle();

    final note = find.byType(NoteInputWidget);
    expect(note, findsOneWidget);
    await tester.ensureVisible(note);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: note, matching: find.byType(EditableText)),
    );
    // The keyboard comes up: 300 dp.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 2.625);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(ExpenseFormActionsWidget));
    final field = tester.getRect(note);
    expect(field.bottom, lessThanOrEqualTo(bar.top));
    expect(tester.takeException(), isNull);
  });
}
