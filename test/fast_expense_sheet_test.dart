import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/expense/fast_input/fast_expense_sheet.dart';
import 'package:io_caravella_egm/manager/expense/fast_input/fast_input_parser.dart';
import 'package:material_ui/material_ui.dart';

/// Home's "+": an expense written in one line (#623).
void main() {
  final food = ExpenseCategory(id: 'f', name: 'Food');
  final transport = ExpenseCategory(id: 't', name: 'Transport');
  final me = ExpenseParticipant(id: 'g', name: 'Gianluigi');
  final anna = ExpenseParticipant(id: 'a', name: 'Anna');
  final group = ExpenseGroup(
    id: 'g1',
    title: 'Norway Road Trip',
    expenses: const [],
    participants: [me, anna],
    categories: [food, transport],
    currency: '€',
  );

  Future<({List<FastInput> saved, List<FastInput> opened})> open(
    WidgetTester tester,
  ) async {
    final saved = <FastInput>[];
    final opened = <FastInput>[];
    await tester.binding.setSurfaceSize(const Size(412, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: FastExpenseSheet(
            group: group,
            // Monday 2 November 2026.
            now: DateTime(2026, 11, 2, 9),
            onSave: (input) async {
              saved.add(input);
              return false;
            },
            onOpenForm: opened.add,
          ),
        ),
      ),
    );
    await tester.pump();
    return (saved: saved, opened: opened);
  }

  testWidgets('a complete line shows what was understood and saves', (
    tester,
  ) async {
    final calls = await open(tester);
    expect(find.text('Norway Road Trip'), findsOneWidget);
    expect(find.text('Type the amount to add'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'coffee 5.50 @yesterday #food +anna',
    );
    // Cursor after a space: no word being completed.
    await tester.enterText(
      find.byType(TextField),
      'coffee 5.50 @yesterday #food +anna ',
    );
    await tester.pump();

    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('5.50 €'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Paid by Anna'), findsOneWidget);

    await tester.tap(find.text('Add 5.50 €'));
    await tester.pump();
    expect(calls.saved, hasLength(1));
    final input = calls.saved.single;
    expect(input.amount, 5.5);
    expect(input.date, DateTime(2026, 11, 1));
    expect(input.category, food);
    expect(input.paidBy, anna);
  });

  testWidgets('# suggests the group categories and completes the word', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'fuel 62 #tr');
    await tester.pump();
    expect(find.text('GROUP CATEGORIES'), findsOneWidget);

    await tester.tap(find.text('Transport'));
    await tester.pump();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'fuel 62 #Transport ');
    expect(find.text('Add 62.00 €'), findsOneWidget);
  });

  testWidgets('a new category is announced; an unknown payer blocks', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'dinner 40 #restaurants ');
    await tester.pump();
    expect(find.text('New: Restaurants'), findsOneWidget);
    expect(find.text('Add 40.00 €'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'dinner 40 +Luca ');
    await tester.pump();
    expect(find.text('+Luca isn’t in the group'), findsOneWidget);
    expect(find.text('Fix the parts in red'), findsOneWidget);
  });

  testWidgets('the full form takes what was written', (tester) async {
    final calls = await open(tester);
    await tester.enterText(find.byType(TextField), 'dinner at the port ');
    await tester.pump();
    expect(find.text('Amount?'), findsOneWidget);

    await tester.tap(find.text('Open the full form'));
    expect(calls.opened.single.name, 'Dinner at the port');
  });
}
