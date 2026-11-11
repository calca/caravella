import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final anna = ExpenseParticipant(id: 'anna', name: 'Anna');
  final food = ExpenseCategory(id: 'food', name: 'Food');

  ExpenseGroup groupWith(
    GroupBudget? budget,
    Map<DateTime, double> expenses, {
    DateTime? start,
    DateTime? end,
  }) => ExpenseGroup(
    title: 'G',
    currency: '€',
    participants: [anna],
    categories: [food],
    startDate: start,
    endDate: end,
    budget: budget,
    expenses: [
      for (final e in expenses.entries)
        ExpenseDetails(
          name: 'x',
          amount: e.value,
          paidBy: anna,
          category: food,
          date: e.key,
        ),
    ],
  );

  test('no budget, no status', () {
    expect(BudgetStatus.of(groupWith(null, {})), isNull);
  });

  group('total', () {
    const budget = GroupBudget(amount: 1500, period: BudgetPeriod.total);

    test('on a trip: today shares what was left before it', () {
      // 16–25 Oct, today the 21st (day 6 of 10). 1110 spent before today,
      // 34.20 today: 390 left over 5 days = 78 a day.
      final s = BudgetStatus.of(
        groupWith(
          budget,
          {DateTime(2026, 10, 17, 9): 1110, DateTime(2026, 10, 21, 12): 34.2},
          start: DateTime(2026, 10, 16),
          end: DateTime(2026, 10, 25),
        ),
        today: DateTime(2026, 10, 21, 18),
      )!;
      expect(s.spent, closeTo(1144.2, 1e-9));
      expect(s.remaining, closeTo(355.8, 1e-9));
      expect(s.spentToday, closeTo(34.2, 1e-9));
      expect(s.dayNumber, 6);
      expect(s.dayCount, 10);
      expect(s.todayShare, closeTo(78, 1e-9));
      expect(s.remainingToday, closeTo(43.8, 1e-9));
      expect(s.overToday, isFalse);
      expect(s.todayFraction, closeTo(34.2 / 78, 1e-9));
      expect(s.averagePerDay, closeTo(1144.2 / 6, 1e-9));
      expect(s.pastPeriods, isEmpty);
    });

    test('without dates: no share for today, still what is left', () {
      final s = BudgetStatus.of(
        groupWith(budget, {DateTime(2026, 10, 17): 1600}),
        today: DateTime(2026, 10, 21),
      )!;
      expect(s.todayShare, isNull);
      expect(s.todayFraction, isNull);
      expect(s.overToday, isFalse);
      expect(s.remaining, -100);
      expect(s.overBy, 100);
    });

    test('after the trip: no share for today', () {
      final s = BudgetStatus.of(
        groupWith(
          budget,
          {DateTime(2026, 10, 17): 100},
          start: DateTime(2026, 10, 16),
          end: DateTime(2026, 10, 25),
        ),
        today: DateTime(2026, 10, 26),
      )!;
      expect(s.todayShare, isNull);
      expect(s.remaining, 1400);
    });

    test('used up before today: over, with a full ring', () {
      final s = BudgetStatus.of(
        groupWith(
          budget,
          {DateTime(2026, 10, 17): 1500},
          start: DateTime(2026, 10, 16),
          end: DateTime(2026, 10, 25),
        ),
        today: DateTime(2026, 10, 21),
      )!;
      expect(s.todayShare, 0);
      expect(s.overToday, isTrue);
      expect(s.todayFraction, 1);
    });
  });

  group('monthly', () {
    const budget = GroupBudget(amount: 600, period: BudgetPeriod.monthly);

    test('this month, and the three before since the first expense', () {
      final s = BudgetStatus.of(
        groupWith(budget, {
          DateTime(2026, 8, 20): 588,
          DateTime(2026, 9, 3): 642,
          DateTime(2026, 10, 31, 23): 560,
          DateTime(2026, 11, 2): 205.9,
          DateTime(2026, 11, 11, 8): 8.4,
        }),
        today: DateTime(2026, 11, 11, 20),
      )!;
      expect(s.start, DateTime(2026, 11, 1));
      expect(s.end, DateTime(2026, 11, 30));
      expect(s.spent, closeTo(214.3, 1e-9));
      expect(s.dayNumber, 11);
      expect(s.dayCount, 30);
      // 394.10 left this morning, over 20 days.
      expect(s.todayShare, closeTo(19.705, 1e-9));
      expect(s.pastPeriods.map((p) => (p.start, p.spent)), [
        (DateTime(2026, 10, 1), 560),
        (DateTime(2026, 9, 1), 642),
        (DateTime(2026, 8, 1), 588),
      ]);
      expect(s.pastPeriods.first.end, DateTime(2026, 10, 31));
    });

    test('a group started last month shows only that one', () {
      final s = BudgetStatus.of(
        groupWith(budget, {DateTime(2026, 10, 20): 100}),
        today: DateTime(2026, 11, 11),
      )!;
      expect(s.pastPeriods.map((p) => p.start), [DateTime(2026, 10, 1)]);
    });

    test('over today: spent more than its share', () {
      final s = BudgetStatus.of(
        groupWith(budget, {DateTime(2026, 11, 30): 50}),
        today: DateTime(2026, 11, 30),
      )!;
      expect(s.todayShare, 600);
      expect(s.overToday, isFalse);
      final over = BudgetStatus.of(
        groupWith(budget, {
          DateTime(2026, 11, 1): 590,
          DateTime(2026, 11, 30): 50,
        }),
        today: DateTime(2026, 11, 30),
      )!;
      expect(over.todayShare, closeTo(10, 1e-9));
      expect(over.overToday, isTrue);
      expect(over.todayFraction, 1);
    });
  });

  group('weekly', () {
    const budget = GroupBudget(amount: 140, period: BudgetPeriod.weekly);

    test('weeks start on the given day', () {
      // Wednesday 11 Nov 2026.
      final today = DateTime(2026, 11, 11);
      final monday = BudgetStatus.of(groupWith(budget, {}), today: today)!;
      expect(monday.start, DateTime(2026, 11, 9));
      expect(monday.end, DateTime(2026, 11, 15));
      expect(monday.dayNumber, 3);
      expect(monday.todayShare, closeTo(140 / 5, 1e-9));

      final sunday = BudgetStatus.of(
        groupWith(budget, {}),
        today: today,
        firstDayOfWeek: DateTime.sunday,
      )!;
      expect(sunday.start, DateTime(2026, 11, 8));
      expect(sunday.end, DateTime(2026, 11, 14));
    });

    test('across a month and a daylight-saving change', () {
      // Week of Monday 26 Oct 2026 (clocks went back on the 25th).
      final s = BudgetStatus.of(
        groupWith(budget, {
          DateTime(2026, 10, 20): 30,
          DateTime(2026, 11, 1, 23, 30): 20,
        }),
        today: DateTime(2026, 11, 2),
      )!;
      expect(s.start, DateTime(2026, 11, 2));
      expect(s.pastPeriods.map((p) => (p.start, p.end, p.spent)), [
        (DateTime(2026, 10, 26), DateTime(2026, 11, 1), 20),
        (DateTime(2026, 10, 19), DateTime(2026, 10, 25), 30),
      ]);
    });
  });

  group('daily', () {
    const budget = GroupBudget(amount: 40, period: BudgetPeriod.daily);

    test('today is the period, its share the amount', () {
      final s = BudgetStatus.of(
        groupWith(budget, {
          DateTime(2026, 11, 9): 45,
          DateTime(2026, 11, 11, 9): 12,
          DateTime(2026, 11, 11, 13): 18,
        }),
        today: DateTime(2026, 11, 11, 15),
      )!;
      expect(s.spent, 30);
      expect(s.todayShare, 40);
      expect(s.remainingToday, 10);
      expect(s.todayFraction, 0.75);
      expect(s.dayNumber, 1);
      expect(s.dayCount, 1);
      expect(s.pastPeriods.map((p) => (p.start, p.spent)), [
        (DateTime(2026, 11, 10), 0),
        (DateTime(2026, 11, 9), 45),
      ]);
    });
  });

  test('GroupBudget JSON: unknown or empty ones read as none', () {
    const b = GroupBudget(amount: 600, period: BudgetPeriod.monthly);
    expect(GroupBudget.fromJson(b.toJson()), b);
    expect(GroupBudget.fromJson(null), isNull);
    expect(GroupBudget.fromJson({'amount': 0, 'period': 'monthly'}), isNull);
    expect(GroupBudget.fromJson({'amount': 10, 'period': 'yearly'}), isNull);
  });
}
