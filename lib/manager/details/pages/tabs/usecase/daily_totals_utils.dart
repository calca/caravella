import 'package:caravella_core/caravella_core.dart';

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
  // Se non ci sono date impostate, usa il range effettivo delle spese
  if (group.startDate == null || group.endDate == null) {
    return buildExpenseRangeSeries(group);
  }

  final rawStart = group.startDate!;
  final rawEnd = group.endDate!;
  final start = DateTime(rawStart.year, rawStart.month, rawStart.day);
  final end = DateTime(rawEnd.year, rawEnd.month, rawEnd.day);
  if (end.isBefore(start)) return const [];
  final duration = end.difference(start).inDays + 1;
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

  final duration = end.difference(start).inDays + 1;
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
  final inclusiveDays = end.difference(start).inDays + 1; // inclusive span
  return inclusiveDays <= 30;
}
