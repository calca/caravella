import 'package:io_caravella_egm/data/model/expense_group.dart';

/// Optimized calculation of daily totals for a given range starting at
/// [startDate] and spanning [days] days. The [startDate] is normalized to
/// midnight to avoid time-of-day skew when computing `inDays` differences.
List<double> calculateDailyTotalsOptimized(
  ExpenseGroup group,
  DateTime startDate,
  int days,
) {
  final baseStart = DateTime(startDate.year, startDate.month, startDate.day);
  final dailyTotals = List<double>.filled(days, 0.0);
  for (final expense in group.expenses) {
    final expenseDate = expense.date;
    final dayDiff = expenseDate.difference(baseStart).inDays;
    if (dayDiff >= 0 && dayDiff < days) {
      dailyTotals[dayDiff] += expense.amount ?? 0;
    }
  }
  return dailyTotals;
}

/// Returns the 7-day weekly series starting from the Monday of current week.
List<double> buildWeeklySeries(ExpenseGroup group) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  return calculateDailyTotalsOptimized(group, startOfWeek, 7);
}

/// Returns the series for the current month (1st to last day).
List<double> buildMonthlySeries(ExpenseGroup group) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final startOfMonth = DateTime(now.year, now.month, 1);
  return calculateDailyTotalsOptimized(group, startOfMonth, daysInMonth);
}

/// If the group qualifies for a date-range chart (<=30 days inclusive),
/// returns that series; otherwise an empty list.
List<double> buildAdaptiveDateRangeSeries(ExpenseGroup group) {
  if (group.startDate == null || group.endDate == null) return const [];
  final rawStart = group.startDate!;
  final rawEnd = group.endDate!;
  final start = DateTime(rawStart.year, rawStart.month, rawStart.day);
  final end = DateTime(rawEnd.year, rawEnd.month, rawEnd.day);
  if (end.isBefore(start)) return const [];
  final duration = end.difference(start).inDays + 1;
  if (duration > 30) return const [];
  return calculateDailyTotalsOptimized(group, start, duration);
}
