import 'package:caravella_core/caravella_core.dart';

/// Calendar days from [a] to [b] (dates only): counted in UTC, so the 23 or
/// 25 hours of a daylight-saving change don't shift the result, and the time
/// of day is ignored.
int calendarDaysBetween(DateTime a, DateTime b) => DateTime.utc(
  b.year,
  b.month,
  b.day,
).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

/// Optimized calculation of daily totals for a given range starting at
/// [startDate] and spanning [days] days, bucketing each expense by its
/// calendar day ([calendarDaysBetween]).
List<double> calculateDailyTotalsOptimized(
  ExpenseGroup group,
  DateTime startDate,
  int days,
) {
  final baseStart = DateTime(startDate.year, startDate.month, startDate.day);
  final dailyTotals = List<double>.filled(days, 0.0);
  for (final expense in group.expenses) {
    final expenseDate = expense.date;
    final dayDiff = calendarDaysBetween(baseStart, expenseDate);
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
  // Se non ci sono date impostate, usa il range effettivo delle spese
  if (group.startDate == null || group.endDate == null) {
    return buildExpenseRangeSeries(group);
  }

  final rawStart = group.startDate!;
  final rawEnd = group.endDate!;
  final start = DateTime(rawStart.year, rawStart.month, rawStart.day);
  final end = DateTime(rawEnd.year, rawEnd.month, rawEnd.day);
  if (end.isBefore(start)) return const [];
  final duration = calendarDaysBetween(start, end) + 1;
  if (duration > 30) return const [];
  return calculateDailyTotalsOptimized(group, start, duration);
}

/// Calcola la serie basata sul range effettivo delle spese (dalla prima all'ultima).
/// Ritorna una lista vuota se non ci sono spese o se il range supera i 30 giorni.
List<double> buildExpenseRangeSeries(ExpenseGroup group) {
  if (group.expenses.isEmpty) return const [];

  final dates = group.expenses.map((e) => e.date).toList()..sort();
  final firstDate = dates.first;
  final lastDate = dates.last;

  final start = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final end = DateTime(lastDate.year, lastDate.month, lastDate.day);

  final duration = calendarDaysBetween(start, end) + 1;
  if (duration > 30) return const [];

  return calculateDailyTotalsOptimized(group, start, duration);
}

/// Decide se mostrare il grafico "date range" (giorno per giorno) nella home.
/// Regola aggiornata: mostra SE:
///  - Le date NON sono impostate (usa il range effettivo delle spese)
///  - OPPURE entrambe le date sono presenti E la durata è <= 30 giorni
/// Esempi con date impostate:
///  - start = 1, end = 1  => 1 giorno (mostra)
///  - start = 1, end = 30 => 30 giorni (mostra)
///  - start = 1, end = 31 => 31 giorni (NON mostra)
/// Senza date impostate:
///  - Usa il range effettivo delle spese se <= 30 giorni
bool shouldShowDateRangeChart(ExpenseGroup group) {
  final start = group.startDate;
  final end = group.endDate;

  // Se non ci sono date impostate, mostra il grafico date range
  // basato sul periodo effettivo delle spese (se valido)
  if (start == null || end == null) {
    final series = buildExpenseRangeSeries(group);
    return series.isNotEmpty;
  }

  // Se ci sono date impostate, mostra solo se <= 30 giorni
  if (end.isBefore(start)) return false; // dati incoerenti
  final inclusiveDays = calendarDaysBetween(start, end) + 1; // inclusive span
  return inclusiveDays <= 30;
}

/// Step of the group spending chart.
enum SpendingStep { day, week, month }

/// The group's spending over its whole period, bucketed by [step].
class SpendingSeries {
  final SpendingStep step;
  final DateTime start;
  final DateTime end;
  final List<double> values;

  const SpendingSeries({
    required this.step,
    required this.start,
    required this.end,
    required this.values,
  });
}

/// One chart for the whole group: from its start date (or first expense) to
/// its end date (or last expense, never past today for an ongoing group),
/// day by day up to 31 days, week by week (from the Monday of the first
/// week) up to ~6 months, month by month beyond. Null without expenses.
SpendingSeries? buildGroupSpendingSeries(ExpenseGroup group, {DateTime? now}) {
  if (group.expenses.isEmpty) return null;
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  final dates = group.expenses.map((e) => day(e.date)).toList()..sort();
  final first = dates.first;
  final last = dates.last;
  final today = day(now ?? DateTime.now());

  var start = group.startDate != null ? day(group.startDate!) : first;
  if (first.isBefore(start)) start = first;
  var end = group.endDate != null ? day(group.endDate!) : last;
  // An ongoing group stops at today (or its last expense, if later).
  final latest = last.isAfter(today) ? last : today;
  if (end.isAfter(latest)) end = latest;
  if (last.isAfter(end)) end = last;

  final days = calendarDaysBetween(start, end) + 1;
  if (days <= 31) {
    return SpendingSeries(
      step: SpendingStep.day,
      start: start,
      end: end,
      values: calculateDailyTotalsOptimized(group, start, days),
    );
  }
  if (days <= 183) {
    final monday = start.subtract(Duration(days: start.weekday - 1));
    final weeks = (calendarDaysBetween(monday, end) ~/ 7) + 1;
    final values = List<double>.filled(weeks, 0);
    for (final e in group.expenses) {
      final i = calendarDaysBetween(monday, e.date) ~/ 7;
      if (i >= 0 && i < weeks) values[i] += e.amount ?? 0;
    }
    return SpendingSeries(
      step: SpendingStep.week,
      start: start,
      end: end,
      values: values,
    );
  }
  final months = (end.year - start.year) * 12 + end.month - start.month + 1;
  final values = List<double>.filled(months, 0);
  for (final e in group.expenses) {
    final i = (e.date.year - start.year) * 12 + e.date.month - start.month;
    if (i >= 0 && i < months) values[i] += e.amount ?? 0;
  }
  return SpendingSeries(
    step: SpendingStep.month,
    start: start,
    end: end,
    values: values,
  );
}
