import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

ExpenseDetails _expense(double amount, DateTime date) => ExpenseDetails(
  name: 'x',
  amount: amount,
  date: date,
  paidBy: _anna,
  category: _food,
);

ExpenseGroup _group(
  List<ExpenseDetails> expenses, {
  DateTime? start,
  DateTime? end,
}) => ExpenseGroup(
  title: 'Trip',
  expenses: expenses,
  participants: [_anna],
  categories: [_food],
  currency: '€',
  startDate: start,
  endDate: end,
);

void main() {
  final today = DateTime(2026, 10, 26);

  test('no expenses, no pace', () {
    expect(SpendingPace.of(_group([]), today: today), isNull);
  });

  test('a trip is averaged over every day of its period', () {
    // 10-day trip, spending on 2 of them.
    final pace = SpendingPace.of(
      _group(
        [
          _expense(60, DateTime(2026, 10, 16, 9)),
          _expense(40, DateTime(2026, 10, 16, 20)),
          _expense(100, DateTime(2026, 10, 21)),
        ],
        start: DateTime(2026, 10, 16),
        end: DateTime(2026, 10, 25),
      ),
      today: today,
    )!;
    expect(pace.unit, SpendingPaceUnit.day);
    expect(pace.periods, 10);
    expect(pace.activePeriods, 2);
    expect(pace.average, 20);
    expect(pace.expenseCount, 3);
    expect(pace.perExpense, closeTo(66.67, 0.01));
    expect(pace.start, DateTime(2026, 10, 16));
    expect(pace.end, DateTime(2026, 10, 25));
  });

  test('a running group counts up to today, not to its end date', () {
    final pace = SpendingPace.of(
      _group(
        [_expense(70, DateTime(2026, 10, 20))],
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 11, 30),
      ),
      today: today,
    )!;
    expect(pace.end, today);
    expect(pace.periods, 7);
    expect(pace.average, 10);
  });

  test('without dates the period runs from the first expense to today', () {
    final pace = SpendingPace.of(
      _group([_expense(50, DateTime(2026, 10, 22))]),
      today: today,
    )!;
    expect(pace.start, DateTime(2026, 10, 22));
    expect(pace.periods, 5);
  });

  test('expenses outside the dates widen the period', () {
    final pace = SpendingPace.of(
      _group(
        [
          _expense(10, DateTime(2026, 10, 1)),
          _expense(10, DateTime(2026, 10, 12)),
        ],
        start: DateTime(2026, 10, 5),
        end: DateTime(2026, 10, 10),
      ),
      today: today,
    )!;
    expect(pace.start, DateTime(2026, 10, 1));
    expect(pace.end, DateTime(2026, 10, 12));
    expect(pace.periods, 12);
  });

  test('groups longer than two months are measured per month', () {
    final pace = SpendingPace.of(
      _group(
        [
          _expense(300, DateTime(2026, 3, 10)),
          _expense(400, DateTime(2026, 5, 2)),
          _expense(700, DateTime(2026, 9, 28)),
        ],
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 9, 30),
      ),
      today: today,
    )!;
    expect(pace.unit, SpendingPaceUnit.month);
    expect(pace.periods, 7);
    expect(pace.activePeriods, 3);
    expect(pace.average, 200);
  });

  test('exactly two months is still per day', () {
    final pace = SpendingPace.of(
      _group(
        [_expense(62, DateTime(2026, 8, 1))],
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 10, 1),
      ),
      today: today,
    )!;
    expect(pace.periods, SpendingPace.monthlyAfterDays);
    expect(pace.unit, SpendingPaceUnit.day);
  });
}
