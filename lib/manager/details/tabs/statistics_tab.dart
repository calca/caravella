import 'package:flutter/material.dart';
import '../../../data/expense_group.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
import 'widgets/daily_expenses_chart.dart';
import 'widgets/categories_pie_chart.dart';
// ...existing code...

class StatisticsTab extends StatelessWidget {
  final ExpenseGroup trip;

  const StatisticsTab({super.key, required this.trip});

  /// Determines whether to use weekly stats based on trip duration
  bool _shouldUseWeeklyStats() {
    // If no dates defined, use weekly
    if (trip.startDate == null || trip.endDate == null) {
      return true;
    }
    
    final duration = trip.endDate!.difference(trip.startDate!);
    // Use weekly if duration > 1 week (7 days)
    return duration.inDays > 7;
  }

  /// Gets the appropriate chart title key based on data type
  String _getChartTitleKey() {
    return _shouldUseWeeklyStats() ? 'weekly_expenses_chart' : 'daily_expenses_chart';
  }
  /// Aggrega le spese per settimana (lunedì-domenica)
  Map<DateTime, double> _calculateWeeklyStats() {
    final dailyStats = _calculateDailyStats();
    final weeklyStats = <DateTime, double>{};
    if (dailyStats.isEmpty) return weeklyStats;

    // Trova il primo giorno (lunedì) e l'ultimo giorno
    final sortedDays = dailyStats.keys.toList()..sort();
    DateTime firstDay = sortedDays.first;
    DateTime lastDay = sortedDays.last;

    // Allinea il primo giorno a lunedì
    firstDay = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    DateTime currentWeekStart = firstDay;
    while (currentWeekStart.isBefore(lastDay) ||
        currentWeekStart.isAtSameMomentAs(lastDay)) {
      double weekTotal = 0.0;
      for (int i = 0; i < 7; i++) {
        final day = currentWeekStart.add(Duration(days: i));
        weekTotal += dailyStats[day] ?? 0.0;
      }
      weeklyStats[currentWeekStart] = weekTotal;
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }
    return weeklyStats;
  }

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

    // Calcola le statistiche aggregate - daily o weekly in base alla durata
    final useWeeklyStats = _shouldUseWeeklyStats();
    final chartStats = useWeeklyStats ? _calculateWeeklyStats() : _calculateDailyStats();
    final chartTitleKey = _getChartTitleKey();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grafico delle spese per giorno o settimana
          DailyExpensesChart(
            trip: trip,
            dailyStats: chartStats,
            loc: loc,
            titleKey: chartTitleKey,
          ),

          const SizedBox(height: 32),

          // Grafico a torta per categorie
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CategoriesPieChart(
                  trip: trip,
                  loc: loc,
                ),
              ),
            ],
          ),

          // ...existing code...
        ],
      ),
    );
  }

  Map<DateTime, double> _calculateDailyStats() {
    final stats = <DateTime, double>{};

    // Se non ci sono date definite, usa il mese corrente
    if (trip.startDate == null || trip.endDate == null) {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      DateTime currentDate = firstDay;
      while (currentDate.isBefore(lastDay) ||
          currentDate.isAtSameMomentAs(lastDay)) {
        stats[currentDate] = 0.0;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      for (final expense in trip.expenses) {
        final date =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        // Solo spese del mese corrente
        if (date.month == now.month && date.year == now.year) {
          stats[date] = (stats[date] ?? 0.0) + (expense.amount ?? 0.0);
        }
      }
      return stats;
    }

    // Inizializza tutti i giorni del viaggio con 0
    DateTime currentDate = DateTime(
        trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
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
