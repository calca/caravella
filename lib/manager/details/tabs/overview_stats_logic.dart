import '../../../data/model/expense_group.dart';

/// Decide se mostrare il grafico "date range" (giorno per giorno) nella home.
/// Regola aggiornata: mostra se entrambe le date sono presenti, end >= start,
/// e il numero di giorni INCLUSIVO (start + end compresi) è <= 30.
/// Esempi:
///  - start = 1, end = 1  => 1 giorno (mostra)
///  - start = 1, end = 30 => 30 giorni (mostra)
///  - start = 1, end = 31 => 31 giorni (NON mostra)
bool shouldShowDateRangeChart(ExpenseGroup group) {
  final start = group.startDate;
  final end = group.endDate;
  if (start == null || end == null) return false;
  if (end.isBefore(start)) return false; // dati incoerenti
  final inclusiveDays = end.difference(start).inDays + 1; // inclusive span
  return inclusiveDays <= 30;
}

/// Calcola i totali giornalieri per un intervallo di giorni a partire da
/// [startDate] (incluso). Ritorna una lista di lunghezza [days] dove ogni
/// indice rappresenta il giorno relativo (0 = startDate).
List<double> calculateDailyTotals(
  ExpenseGroup group,
  DateTime startDate,
  int days,
) {
  final dailyTotals = List<double>.filled(days, 0.0);

  for (final expense in group.expenses) {
    final expenseDate = expense.date;
    final dayDiff = expenseDate.difference(startDate).inDays;
    if (dayDiff < 0 || dayDiff >= days) continue;

    // Verifica di essere esattamente lo stesso giorno (stesso y/m/d)
    final targetDay = startDate.add(Duration(days: dayDiff));
    if (expenseDate.year == targetDay.year &&
        expenseDate.month == targetDay.month &&
        expenseDate.day == targetDay.day) {
      dailyTotals[dayDiff] += expense.amount ?? 0;
    }
  }

  return dailyTotals;
}
