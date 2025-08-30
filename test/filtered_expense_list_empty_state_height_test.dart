import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/widgets/filtered_expense_list.dart';
import 'package:io_caravella_egm/manager/details/widgets/empty_expense_state.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';

void main() {
  testWidgets('FilteredExpenseList empty state uses responsive height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FilteredExpenseList(
            expenses: const <ExpenseDetails>[],
            currency: 'EUR',
            onExpenseTap: (_) {},
            categories: const <ExpenseCategory>[],
            participants: const <ExpenseParticipant>[],
            onAddExpense: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the EmptyExpenseState
    final emptyFinder = find.byType(EmptyExpenseState);
    expect(emptyFinder, findsOneWidget);

    // Get the SizedBox ancestor that enforces height
    final box = tester.firstWidget<SizedBox>(
      find.ancestor(of: emptyFinder, matching: find.byType(SizedBox)).first,
    );

    // Height should respect clamp range 420..560 from widget logic
    expect(box.height, isNotNull);
    expect(box.height! >= 420 - 0.5, true);
    expect(box.height! <= 560 + 0.5, true);
  });
}
