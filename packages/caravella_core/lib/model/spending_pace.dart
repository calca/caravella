import 'expense_group.dart';

/// Unit of a [SpendingPace]: per day for trips and other short groups, per
/// month for long ones (shared flats, running budgets).
enum SpendingPaceUnit { day, month }

/// How fast a group spends: its total spread over the whole period, in days
/// or months, with the counts the statistics card shows next to it.
class SpendingPace {
  /// Groups longer than this many days are measured per month.
  static const int monthlyAfterDays = 62;

  final SpendingPaceUnit unit;

  /// First and last day the average is spread over (calendar days).
  final DateTime start;
  final DateTime end;

  /// Days or months (per [unit]) from [start] to [end], both included.
  final int periods;

  /// Days or months (per [unit]) with at least one expense.
  final int activePeriods;

  final double total;
  final int expenseCount;

  const SpendingPace({
    required this.unit,
    required this.start,
    required this.end,
    required this.periods,
    required this.activePeriods,
    required this.total,
    required this.expenseCount,
  });

  /// Total spread over every day or month of the period, including the ones
  /// without expenses.
  double get average => total / periods;

  double get perExpense => total / expenseCount;

  /// The pace of [group], or null when it has no expenses.
  ///
  /// The period runs from the group's start date (or its first expense) to
  /// its end date (or [today], for a group without one or still running),
  /// and always covers every expense.
  static SpendingPace? of(ExpenseGroup group, {DateTime? today}) {
    if (group.expenses.isEmpty) return null;
    final days = group.expenses.map((e) => _day(e.date)).toList()..sort();
    final now = _day(today ?? DateTime.now());

    var start = days.first;
    if (group.startDate case final s? when _day(s).isBefore(start)) {
      start = _day(s);
    }
    var end = group.endDate == null ? now : _day(group.endDate!);
    if (end.isAfter(now)) end = now;
    if (days.last.isAfter(end)) end = days.last;
    if (end.isBefore(start)) end = start;

    final dayCount = _daysBetween(start, end) + 1;
    final monthly = dayCount > monthlyAfterDays;
    return SpendingPace(
      unit: monthly ? SpendingPaceUnit.month : SpendingPaceUnit.day,
      start: start,
      end: end,
      periods: monthly
          ? (end.year - start.year) * 12 + end.month - start.month + 1
          : dayCount,
      activePeriods: monthly
          ? days.map((d) => DateTime(d.year, d.month)).toSet().length
          : days.toSet().length,
      total: group.getTotalExpenses(),
      expenseCount: group.expenses.length,
    );
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  // UTC so a daylight-saving change in the range doesn't lose an hour.
  static int _daysBetween(DateTime a, DateTime b) => DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}
