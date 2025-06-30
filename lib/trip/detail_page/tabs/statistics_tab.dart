import 'package:flutter/material.dart';
import '../../../data/expense_group.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
import 'widgets/daily_expenses_chart.dart';
import 'widgets/categories_pie_chart.dart';
import 'widgets/general_stats.dart';

class StatisticsTab extends StatelessWidget {
  final ExpenseGroup trip;

  const StatisticsTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'en');

    if (trip.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              loc.get('no_expenses_for_statistics'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    // Calcola le statistiche per giorni
    final dailyStats = _calculateDailyStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grafico delle spese per giorno
          DailyExpensesChart(
            trip: trip,
            dailyStats: dailyStats,
            loc: loc,
          ),

          const SizedBox(height: 32),

          // Grafico a torta per categorie
          CategoriesPieChart(
            trip: trip,
            loc: loc,
          ),

          const SizedBox(height: 32),

          // Statistiche generali
          GeneralStats(
            trip: trip,
            loc: loc,
          ),
        ],
      ),
    );
  }

  Map<DateTime, double> _calculateDailyStats() {
    final stats = <DateTime, double>{};

    // Se non ci sono date definite, usa solo le date delle spese
    if (trip.startDate == null || trip.endDate == null) {
      for (final expense in trip.expenses) {
        final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
        stats[date] = (stats[date] ?? 0.0) + (expense.amount ?? 0.0);
      }
      return stats;
    }

    // Inizializza tutti i giorni del viaggio con 0
    DateTime currentDate =
        DateTime(trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
    final endDate =
        DateTime(trip.endDate!.year, trip.endDate!.month, trip.endDate!.day);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      stats[currentDate] = 0.0;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Aggiungi le spese reali
    for (final expense in trip.expenses) {
      if (expense.amount != null) {
        final expenseDate =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        stats[expenseDate] = (stats[expenseDate] ?? 0.0) + expense.amount!;
      }
    }

    return stats;
  }
}
