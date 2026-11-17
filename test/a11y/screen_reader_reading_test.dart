import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/budget/budget_detail_sheet.dart';
import 'package:io_caravella_egm/manager/budget/budget_settings_sheet.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_statistics_view.dart';
import 'package:io_caravella_egm/manager/details/widgets/grouped_expense_list.dart';
import 'package:material_ui/material_ui.dart';

/// What TalkBack reads, from the 2.5 accessibility pass: an amount is one
/// stop with its currency, a figure reads with its label, nothing is read
/// twice, and controls keep their 48 dp with large text.

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

ExpenseDetails _expense(String name, double amount, DateTime date) =>
    ExpenseDetails(
      name: name,
      amount: amount,
      date: date,
      paidBy: _anna,
      category: _food,
    );

Widget _wrap(Widget child, {double textScale = 1}) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: MediaQuery.withClampedTextScaling(
    minScaleFactor: textScale,
    maxScaleFactor: textScale,
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('an amount reads once, with its currency', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const CurrencyDisplay(value: 42, currency: '€', showDecimals: true),
      ),
    );
    expect(find.bySemanticsLabel('42.00 €'), findsOneWidget);
    expect(find.bySemanticsLabel('€'), findsNothing);
    handle.dispose();
  });

  testWidgets('a figure reads its label and amount together', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const FigureRow(
          color: Colors.black,
          items: [
            FigureRowItem(label: 'Total', value: 42, currency: '€'),
            FigureRowItem(label: 'Today', value: 12, currency: '€'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp(r'^Total\n42\.00 €$')), findsOne);
    expect(find.bySemanticsLabel(RegExp(r'^Today\n12\.00 €$')), findsOne);
    handle.dispose();
  });

  testWidgets('the budget sheet reads what is left in one stop', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final today = DateTime(2026, 11, 11, 18);
    await tester.pumpWidget(
      _wrap(
        BudgetDetailSheet(
          group: ExpenseGroup(
            title: 'Norway',
            currency: '€',
            participants: [_anna],
            categories: [_food],
            budget: const GroupBudget(amount: 60, period: BudgetPeriod.daily),
            expenses: [_expense('Pizza', 42, DateTime(2026, 11, 11, 12))],
          ),
          today: today,
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp(r'^18\.00 €\nleft$')), findsOne);
    handle.dispose();
  });

  testWidgets('the budget period keeps 48 dp at 200% text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const BudgetSettingsSheet(budget: null, currency: '€'),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['In total', 'Monthly', 'Weekly', 'Daily']) {
      final segment = find.ancestor(
        of: find.text(label),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getRect(segment.first).height,
        greaterThanOrEqualTo(48),
        reason: label,
      );
    }
  });

  testWidgets('a week header is its own heading, not part of a row', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              WeekGroupedExpenseSliver(
                expenses: [_expense('Pizza', 42, DateTime.now())],
                currency: '€',
                onExpenseTap: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    final header = tester.getSemantics(find.text('THIS WEEK'));
    expect(header.label, 'THIS WEEK');
    expect(header.flagsCollection.isHeader, isTrue);
    expect(find.bySemanticsLabel(RegExp(r'^Pizza, ')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the spending pace reads its period once', (tester) async {
    final handle = tester.ensureSemantics();
    final now = DateTime.now();
    await tester.pumpWidget(
      _wrap(
        GroupStatisticsView(
          group: ExpenseGroup(
            title: 'Norway',
            currency: '€',
            participants: [_anna],
            categories: [_food],
            expenses: [_expense('Pizza', 42, now)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pace = find.bySemanticsLabel(RegExp(r'^Spending pace'));
    expect(pace, findsOneWidget);
    final label = tester.getSemantics(pace).label;
    expect(RegExp('Over 1 day').allMatches(label), hasLength(1));
    handle.dispose();
  });

  testWidgets('the day-by-day chart reads its amounts', (tester) async {
    final handle = tester.ensureSemantics();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await tester.pumpWidget(
      _wrap(
        GroupStatisticsView(
          group: ExpenseGroup(
            title: 'Norway',
            currency: '€',
            participants: [_anna],
            categories: [_food],
            startDate: today.subtract(const Duration(days: 2)),
            endDate: today,
            expenses: [
              _expense('Pizza', 42, today),
              _expense('Train', 12, today.subtract(const Duration(days: 2))),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'^Date range expenses\. .+: 12.*; .+: 42')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
