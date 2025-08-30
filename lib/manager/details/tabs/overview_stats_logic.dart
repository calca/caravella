import 'package:io_caravella_egm/data/model/expense_group.dart';

/// Decide se usare aggregazione settimanale per i grafici.
/// Regola: se mancano date oppure durata > 7 giorni.
bool useWeeklyAggregation(ExpenseGroup trip) {
  if (trip.startDate == null || trip.endDate == null) return true;
  final duration = trip.endDate!.difference(trip.startDate!);
  return duration.inDays > 7; // strictly greater than 7
}

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
