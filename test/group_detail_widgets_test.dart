import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/daily_totals_utils.dart';
import 'package:io_caravella_egm/manager/details/widgets/expense_day_row.dart';
import 'package:io_caravella_egm/manager/details/widgets/grouped_expense_list.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_balances_view.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_map_card.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_statistics_view.dart';
import 'package:material_ui/material_ui.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _luca = ExpenseParticipant(id: 'l', name: 'Luca');
final _food = ExpenseCategory(id: 'f', name: 'Food');

ExpenseDetails _expense(
  String name,
  double amount,
  DateTime date,
  ExpenseParticipant by, {
  ExpenseLocation? location,
}) => ExpenseDetails(
  name: name,
  amount: amount,
  date: date,
  paidBy: by,
  category: _food,
  location: location,
);

ExpenseGroup _group(List<ExpenseDetails> expenses) => ExpenseGroup(
  title: 'Rome',
  expenses: expenses,
  participants: [_anna, _luca],
  categories: [_food],
  currency: '€',
);

Widget _wrap(Widget child, {bool sliver = false}) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(
    body: sliver
        ? CustomScrollView(slivers: [child])
        : SingleChildScrollView(child: child),
  ),
);

void main() {
  final day1 = DateTime(2026, 10, 16, 9);
  final day2 = DateTime(2026, 10, 17, 20);

  test('groupByDay groups by calendar day, newest first', () {
    final days = WeekGroupedExpenseSliver.groupByDay([
      _expense('Breakfast', 10, day1, _anna),
      _expense('Dinner', 40, day2, _luca),
      _expense('Lunch', 20, day1.add(const Duration(hours: 4)), _luca),
    ]);
    expect(days.map((d) => d.$1.day), [17, 16]);
    expect(days.last.$2.map((e) => e.name), ['Lunch', 'Breakfast']);
  });

  test('groupByWeek groups Monday to Sunday, newest first', () {
    final weeks = WeekGroupedExpenseSliver.groupByWeek([
      _expense('Sun', 10, DateTime(2026, 10, 18), _anna),
      _expense('Mon', 20, DateTime(2026, 10, 12), _luca),
      _expense('Prev Sun', 5, DateTime(2026, 10, 11), _luca),
    ]);
    expect(weeks.map((w) => w.$1), [
      DateTime(2026, 10, 12),
      DateTime(2026, 10, 5),
    ]);
    expect(weeks.first.$2.map((e) => e.name), ['Sun', 'Mon']);
  });

  testWidgets('week sections show the week and its total', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeekGroupedExpenseSliver(
          expenses: [
            _expense('Breakfast', 10, DateTime(2025, 3, 4), _anna),
            _expense('Lunch', 20, DateTime(2025, 3, 6), _luca),
          ],
          currency: '€',
          onExpenseTap: (_) {},
        ),
        sliver: true,
      ),
    );
    expect(find.text('3 MAR 2025 – 9 MAR 2025'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('the current week is named', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeekGroupedExpenseSliver(
          expenses: [_expense('Today', 10, DateTime.now(), _anna)],
          currency: '€',
          onExpenseTap: (_) {},
        ),
        sliver: true,
      ),
    );
    expect(find.text('THIS WEEK'), findsOneWidget);
  });

  testWidgets('balances show who gets back, who owes and how to settle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        GroupBalancesView(group: _group([_expense('Hotel', 100, day1, _anna)])),
      ),
    );
    expect(find.bySemanticsLabel('Anna gets back 50.00 €'), findsOneWidget);
    expect(find.bySemanticsLabel('Luca owes 50.00 €'), findsOneWidget);
    expect(find.bySemanticsLabel('Luca pays Anna 50.00 €'), findsOneWidget);
  });

  testWidgets('balances start from the share per person', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GroupBalancesView(group: _group([_expense('Hotel', 100, day1, _anna)])),
      ),
    );
    expect(find.text('Share per person'), findsOneWidget);
    expect(find.textContaining('÷ 2 participants'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Share per person: 50')),
      findsOneWidget,
    );
  });

  testWidgets('balances say when everyone is even', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GroupBalancesView(
          group: _group([
            _expense('Hotel', 50, day1, _anna),
            _expense('Dinner', 50, day2, _luca),
          ]),
        ),
      ),
    );
    expect(find.text('All settled up'), findsOneWidget);
  });

  test('payer avatars grow with what they paid', () {
    expect(
      GroupPayersBubbles.sizeFor(100, 100),
      greaterThan(GroupPayersBubbles.sizeFor(25, 100)),
    );
    expect(
      GroupPayersBubbles.sizeFor(0, 100),
      GroupPayersBubbles.sizeFor(0, 0),
    );
  });

  test('places are counted once per spot', () {
    ExpenseLocation at(double lat, double lon) =>
        ExpenseLocation(latitude: lat, longitude: lon);
    final group = _group([
      _expense('A', 1, day1, _anna, location: at(45.0001, 9.0001)),
      _expense('B', 1, day1, _anna, location: at(45.0002, 9.0002)),
      _expense('C', 1, day1, _anna, location: at(46, 10)),
      _expense('D', 1, day1, _anna),
    ]);
    expect(groupPlacesCount(group), 2);
    expect(groupPlacesCount(_group([])), 0);
  });

  test('highest expense and most expensive day', () {
    final group = _group([
      _expense('Breakfast', 10, day1, _anna),
      _expense('Lunch', 30, day1.add(const Duration(hours: 4)), _luca),
      _expense('Dinner', 35, day2, _luca),
    ]);
    expect(highestExpense(group)?.name, 'Dinner');
    final (day, total) = mostExpensiveDay(group)!;
    expect(day, DateTime(2026, 10, 16));
    expect(total, 40);
    expect(highestExpense(_group([])), isNull);
    expect(mostExpensiveDay(_group([])), isNull);
  });

  group('map card', () {
    final placed = _expense(
      'Lunch',
      10,
      day1,
      _anna,
      location: ExpenseLocation(latitude: 45, longitude: 9),
    );

    testWidgets('with places: opens the map', (tester) async {
      await tester.pumpWidget(_wrap(GroupMapCard(group: _group([placed]))));
      expect(find.text('1 place'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('no places, location off: leads to the setting', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        _wrap(
          GroupMapCard(
            group: _group([_expense('Lunch', 10, day1, _anna)]),
            onEnableLocation: () => opened++,
          ),
        ),
      );
      expect(find.textContaining('Turn on automatic location'), findsOneWidget);
      await tester.tap(find.byType(GroupMapCard));
      expect(opened, 1);
    });

    testWidgets('no places, location on: a note, not tappable', (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        _wrap(
          GroupMapCard(
            group: _group([
              _expense('Lunch', 10, day1, _anna),
            ]).copyWith(autoLocationEnabled: true),
            onEnableLocation: () => opened++,
          ),
        ),
      );
      expect(find.text('No expenses with a place yet'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      await tester.tap(find.byType(GroupMapCard));
      expect(opened, 0);
    });
  });

  testWidgets('statistics at 200% text: no overflow, records stacked', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final group = _group([
      _expense('Breakfast', 10, day1, _anna),
      _expense('Dinner', 35, day2, _luca),
    ]);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _wrap(GroupStatisticsView(group: group)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final highest = tester.getTopLeft(find.text('Highest expense'));
    final day = tester.getTopLeft(find.text('Most expensive day'));
    expect(day.dy, greaterThan(highest.dy), reason: 'one per row');
  });

  test('most expensive month', () {
    final group = _group([
      _expense('Rent', 500, DateTime(2026, 9, 1), _anna),
      _expense('Bills', 120, DateTime(2026, 9, 20), _luca),
      _expense('Rent', 550, DateTime(2026, 10, 1), _anna),
    ]);
    final (month, total) = mostExpensiveMonth(group)!;
    expect(month, DateTime(2026, 9));
    expect(total, 620);
    expect(mostExpensiveMonth(_group([])), isNull);
  });

  testWidgets('spending pace: average per day, over what, and counts', (
    tester,
  ) async {
    final pace = SpendingPace(
      unit: SpendingPaceUnit.day,
      start: DateTime(2026, 10, 16),
      end: DateTime(2026, 10, 25),
      periods: 10,
      activePeriods: 8,
      total: 1354.80,
      expenseCount: 14,
    );
    await tester.pumpWidget(_wrap(SpendingPaceCard(pace: pace, currency: '€')));
    expect(find.text('SPENDING PACE'), findsOneWidget);
    expect(find.text('per day'), findsOneWidget);
    expect(find.textContaining('Average over 10 days'), findsOneWidget);
    expect(find.text('14 expenses'), findsOneWidget);
    expect(find.textContaining('per expense'), findsOneWidget);
    expect(find.text('8 of 10 days with expenses'), findsOneWidget);
  });

  testWidgets('spending pace: long groups are per month', (tester) async {
    final pace = SpendingPace(
      unit: SpendingPaceUnit.month,
      start: DateTime(2026, 3, 1),
      end: DateTime(2026, 9, 30),
      periods: 7,
      activePeriods: 3,
      total: 1400,
      expenseCount: 3,
    );
    await tester.pumpWidget(_wrap(SpendingPaceCard(pace: pace, currency: '€')));
    expect(find.text('per month'), findsOneWidget);
    expect(find.textContaining('Average over 7 months'), findsOneWidget);
    expect(find.text('3 of 7 months with expenses'), findsOneWidget);
  });

  group('one spending chart, step by length', () {
    final now = DateTime(2026, 10, 19);
    ExpenseGroup span(DateTime from, DateTime to) => _group([
      _expense('first', 10, from, _anna),
      _expense('last', 20, to, _luca),
    ]);

    test('up to 31 days: day by day over the whole period', () {
      final s = buildGroupSpendingSeries(
        span(DateTime(2026, 10, 1), DateTime(2026, 10, 10)),
        now: now,
      )!;
      expect(s.step, SpendingStep.day);
      expect(s.values.length, 10);
      expect(s.values.first, 10);
      expect(s.values.last, 20);
    });

    test('up to ~6 months: week by week', () {
      final s = buildGroupSpendingSeries(
        span(DateTime(2026, 6, 1), DateTime(2026, 8, 30)),
        now: now,
      )!;
      expect(s.step, SpendingStep.week);
      expect(s.values.reduce((a, b) => a + b), 30);
    });

    test('longer: month by month', () {
      final s = buildGroupSpendingSeries(
        span(DateTime(2025, 1, 15), DateTime(2026, 3, 2)),
        now: now,
      )!;
      expect(s.step, SpendingStep.month);
      expect(s.values.length, 15);
      expect(s.values.first, 10);
      expect(s.values.last, 20);
    });

    test('an ongoing group stops at today', () {
      final g = ExpenseGroup(
        title: 'Flat',
        expenses: [_expense('rent', 100, DateTime(2026, 10, 3), _anna)],
        participants: [_anna],
        currency: '€',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2027, 6, 30),
      );
      final s = buildGroupSpendingSeries(g, now: now)!;
      expect(s.step, SpendingStep.day);
      expect(s.end, now);
    });
  });

  testWidgets('balances: share the summary or a reminder', (tester) async {
    final shared = <String>[];
    await tester.pumpWidget(
      _wrap(
        GroupBalancesView(
          group: _group([_expense('Hotel', 100, day1, _anna)]),
          share: (text) async => shared.add(text),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Send reminder: Luca'));
    await tester.tap(find.text('Share balances'));
    expect(shared, [
      'Hi Luca! For “Rome” you owe 50.00 € to Anna.',
      'Rome · balances\nLuca → Anna: 50.00 €\n'
          'Total 100.00 € · 50.00 € per person',
    ]);
  });

  testWidgets('expense row: calendar date, payer · category, amount', (
    tester,
  ) async {
    final e = _expense('Ferry', 86, DateTime(2026, 10, 16, 9), _luca);
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            ExpenseDayRow(expense: e, currency: '€', onTap: () => tapped++),
            ExpenseDayRow(expense: e, currency: '€', showMonth: true),
          ],
        ),
      ),
    );
    expect(find.text('FRI'), findsOneWidget);
    expect(find.text('OCT'), findsOneWidget);
    expect(find.text('16'), findsNWidgets(2));
    expect(find.text('Luca · Food'), findsNWidgets(2));
    await tester.tap(find.text('FRI'));
    expect(tapped, 1);
    expect(
      find.bySemanticsLabel(RegExp(r'^Ferry, Luca · Food, Friday, October 16')),
      findsNWidgets(2),
    );
  });
}
