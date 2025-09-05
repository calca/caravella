import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import 'widgets/daily_expenses_chart.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'widgets/stat_card.dart';

/// General statistics tab: shows high level KPIs (daily/monthly average)
/// and spending trend for the last 7 and 30 days.
class GeneralOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const GeneralOverviewTab({super.key, required this.trip});

  double _total() => trip.expenses.fold(0.0, (s, e) => s + (e.amount ?? 0));

  double _dailyAverage() {
    if (trip.expenses.isEmpty) return 0;
    // Distinct days with at least one expense for fairer average
    final days = trip.expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .length;
    return days == 0 ? 0 : _total() / days;
  }

  double _monthlyAverage() {
    if (trip.expenses.isEmpty) return 0;
    final sorted = trip.expenses.map((e) => e.date).toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    int months = (last.year - first.year) * 12 + (last.month - first.month) + 1;
    if (months <= 0) months = 1;
    return _total() / months;
  }

  Map<DateTime, double> _lastNDays(int n) {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: n - 1));
    final map = <DateTime, double>{};
    for (int i = 0; i < n; i++) {
      final d = start.add(Duration(days: i));
      map[d] = 0;
    }
    for (final e in trip.expenses) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (d.isBefore(start)) continue;
      if (d.isAfter(now)) continue;
      map[d] = (map[d] ?? 0) + (e.amount ?? 0);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (trip.expenses.isEmpty) {
      return Center(
        child: Text(
          gloc.no_expenses_for_statistics,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final dailyAvg = _dailyAverage();
    final monthlyAvg = _monthlyAverage();
    final last7 = _lastNDays(7);
    final last30 = _lastNDays(30);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: gloc.daily_average,
                  value: dailyAvg,
                  currency: trip.currency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title:
                      'Mese', // Keeping short neutral label (not yet localized)
                  value: monthlyAvg,
                  currency: trip.currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Last 7 days chart
          Text(
            'Ultimi 7 giorni',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DailyExpensesChart(
            trip: trip,
            dailyStats: last7,
            customTitle:
                gloc.daily_expenses_chart, // Chart has internal title row
          ),
          const SizedBox(height: 32),
          Text(
            'Ultimi 30 giorni',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DailyExpensesChart(
            trip: trip,
            dailyStats: last30,
            customTitle: gloc.daily_expenses_chart,
          ),
        ],
      ),
    );
  }
}
