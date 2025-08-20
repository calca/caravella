import 'package:org_app_caravella/data/expense_group.dart';

/// Decide se usare aggregazione settimanale per i grafici.
/// Regola: se mancano date oppure durata > 7 giorni.
bool useWeeklyAggregation(ExpenseGroup trip) {
  if (trip.startDate == null || trip.endDate == null) return true;
  final duration = trip.endDate!.difference(trip.startDate!);
  return duration.inDays > 7; // strictly greater than 7
}

/// Decide se mostrare solo un grafico da-a per la home page.
/// Regola: se entrambe le date sono impostate e durata ≤ 30 giorni (1 mese).
bool shouldShowDateRangeChart(ExpenseGroup group) {
	if (group.startDate == null || group.endDate == null) return false;
	final duration = group.endDate!.difference(group.startDate!);
	return duration.inDays >= 0 && duration.inDays <= 30; // 0 to 30 days inclusive
}

