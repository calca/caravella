import 'expense_group.dart';
import 'group_budget.dart';

/// What one past period spent, for the comparison under the budget.
class BudgetPastPeriod {
  /// First and last day of the period (calendar days, both included).
  final DateTime start;
  final DateTime end;
  final double spent;

  const BudgetPastPeriod({
    required this.start,
    required this.end,
    required this.spent,
  });
}

/// How a group is doing against its [GroupBudget] on a given day: the
/// figures behind the ring in "Today" and the budget sheet.
///
/// "Today's share" is what can be spent today and still end the period on
/// budget: the daily amount for a daily budget; otherwise what was left at
/// the start of today, spread over the days left (today included). It is
/// fixed for the day, so spending today fills the ring instead of moving
/// its target.
class BudgetStatus {
  /// How many past periods [pastPeriods] holds at most.
  static const int pastPeriodCount = 3;

  final GroupBudget budget;

  /// First and last day of the current period; null for a total budget on
  /// a group without dates.
  final DateTime? start;
  final DateTime? end;

  /// Spent in the current period (for a total budget: in the whole group).
  final double spent;

  final double spentToday;

  /// What can be spent today ([BudgetStatus] explains how it is worked out);
  /// null when there is no day to spread it on: a total budget without
  /// dates, or today outside the group's dates.
  final double? todayShare;

  /// Today's day in the period (1 is the first) and the days in it; null
  /// when [todayShare] is.
  final int? dayNumber;
  final int? dayCount;

  /// The last [pastPeriodCount] periods, newest first, since the group's
  /// first expense; empty for a total budget.
  final List<BudgetPastPeriod> pastPeriods;

  const BudgetStatus({
    required this.budget,
    required this.start,
    required this.end,
    required this.spent,
    required this.spentToday,
    required this.todayShare,
    required this.dayNumber,
    required this.dayCount,
    required this.pastPeriods,
  });

  /// Left in the current period; negative when over it.
  double get remaining => budget.amount - spent;

  /// Spent over the budget of the current period, 0 when within it.
  double get overBy => spent > budget.amount ? spent - budget.amount : 0;

  /// Left of [todayShare]; negative when over it.
  double? get remainingToday => switch (todayShare) {
    final share? => share - spentToday,
    null => null,
  };

  /// Today is over its share: spent more than it, or nothing was left of
  /// the period to share.
  bool get overToday => switch (todayShare) {
    final share? => share <= 0 || spentToday > share,
    null => false,
  };

  /// How full the ring is, 0 to 1 (full when [overToday]); null without a
  /// [todayShare].
  double? get todayFraction => switch (todayShare) {
    null => null,
    _ when overToday => 1,
    final share => (spentToday / share).clamp(0.0, 1.0),
  };

  /// Average spent per day so far in the period; null when [dayNumber] is.
  double? get averagePerDay => switch (dayNumber) {
    final day? => spent / day,
    null => null,
  };

  /// The status of [group] on [today] (default: now), or null when it has
  /// no budget. Weeks start on [firstDayOfWeek] ([DateTime.monday] to
  /// [DateTime.sunday]), as in the user's language.
  static BudgetStatus? of(
    ExpenseGroup group, {
    DateTime? today,
    int firstDayOfWeek = DateTime.monday,
  }) {
    final budget = group.budget;
    if (budget == null) return null;
    final now = _day(today ?? DateTime.now());

    double spentBetween(DateTime? from, DateTime? to) {
      var sum = 0.0;
      for (final e in group.expenses) {
        final d = _day(e.date);
        if (from != null && d.isBefore(from)) continue;
        if (to != null && d.isAfter(to)) continue;
        sum += e.amount ?? 0;
      }
      return sum;
    }

    final spentToday = spentBetween(now, now);

    if (budget.period == BudgetPeriod.total) {
      final start = group.startDate == null ? null : _day(group.startDate!);
      final end = group.endDate == null ? null : _day(group.endDate!);
      final spent = spentBetween(null, null);
      int? dayNumber;
      int? dayCount;
      double? share;
      if (start != null &&
          end != null &&
          !now.isBefore(start) &&
          !now.isAfter(end)) {
        dayNumber = _daysBetween(start, now) + 1;
        dayCount = _daysBetween(start, end) + 1;
        share = _share(budget.amount, spent - spentToday, dayCount, dayNumber);
      }
      return BudgetStatus(
        budget: budget,
        start: start,
        end: end,
        spent: spent,
        spentToday: spentToday,
        todayShare: share,
        dayNumber: dayNumber,
        dayCount: dayCount,
        pastPeriods: const [],
      );
    }

    final (start, end) = _periodAround(budget.period, now, firstDayOfWeek);
    final spent = spentBetween(start, end);
    final dayNumber = _daysBetween(start, now) + 1;
    final dayCount = _daysBetween(start, end) + 1;

    final firstExpense = group.expenses.isEmpty
        ? null
        : group.expenses.map((e) => _day(e.date)).reduce(_earlier);
    final past = <BudgetPastPeriod>[];
    var previousEnd = start.subtract(const Duration(hours: 12));
    while (firstExpense != null && past.length < pastPeriodCount) {
      final (s, e) = _periodAround(
        budget.period,
        _day(previousEnd),
        firstDayOfWeek,
      );
      if (e.isBefore(firstExpense)) break;
      past.add(BudgetPastPeriod(start: s, end: e, spent: spentBetween(s, e)));
      previousEnd = s.subtract(const Duration(hours: 12));
    }

    return BudgetStatus(
      budget: budget,
      start: start,
      end: end,
      spent: spent,
      spentToday: spentToday,
      todayShare: budget.period == BudgetPeriod.daily
          ? budget.amount
          : _share(budget.amount, spent - spentToday, dayCount, dayNumber),
      dayNumber: dayNumber,
      dayCount: dayCount,
      pastPeriods: past,
    );
  }

  /// What was left before today, over the days left (today included);
  /// never below 0.
  static double _share(
    double amount,
    double spentBefore,
    int dayCount,
    int dayNumber,
  ) {
    final left = amount - spentBefore;
    if (left <= 0) return 0;
    return left / (dayCount - dayNumber + 1);
  }

  /// First and last day of the [period] that holds [day].
  static (DateTime, DateTime) _periodAround(
    BudgetPeriod period,
    DateTime day,
    int firstDayOfWeek,
  ) {
    switch (period) {
      case BudgetPeriod.daily:
      case BudgetPeriod.total:
        return (day, day);
      case BudgetPeriod.weekly:
        final back = (day.weekday - firstDayOfWeek + 7) % 7;
        final start = DateTime(day.year, day.month, day.day - back);
        return (start, DateTime(start.year, start.month, start.day + 6));
      case BudgetPeriod.monthly:
        return (
          DateTime(day.year, day.month),
          DateTime(day.year, day.month + 1, 0),
        );
    }
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  /// Calendar days from [a] to [b], unaffected by daylight saving.
  static int _daysBetween(DateTime a, DateTime b) => DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}
