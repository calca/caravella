import 'package:org_app_caravella/data/expense_group.dart';

/// Decide se usare aggregazione settimanale per i grafici.
/// Regola: se mancano date oppure durata > 7 giorni.
bool useWeeklyAggregation(ExpenseGroup trip) {
	if (trip.startDate == null || trip.endDate == null) return true;
	final duration = trip.endDate!.difference(trip.startDate!);
	return duration.inDays > 7; // strictly greater than 7
}

