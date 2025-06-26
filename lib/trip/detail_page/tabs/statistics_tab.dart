import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/expense.dart';
import '../../../data/trip.dart';
import '../../../app_localizations.dart';

class StatisticsTab extends StatelessWidget {
  final Trip? trip;
  const StatisticsTab({super.key, this.trip});

  List<FlSpot> _buildExpenseSpots(List<Expense> expenses) {
    if (expenses.isEmpty) return [];
    // Raggruppa per giorno
    final Map<DateTime, double> dailyTotals = {};
    for (final e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + (e.amount ?? 0);
    }
    final sortedDays = dailyTotals.keys.toList()..sort();
    final last15 = sortedDays.length > 15
        ? sortedDays.sublist(sortedDays.length - 15)
        : sortedDays;
    return List.generate(last15.length, (i) {
      final day = last15[i];
      return FlSpot(i.toDouble(), dailyTotals[day]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context).languageCode);
    final trip = this.trip;
    if (trip == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart,
                size: 48,
                color:
                    theme.colorScheme.primary.withAlpha((0.3 * 255).toInt())),
            const SizedBox(height: 12),
            Text(loc.get('no_data'), style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }
    final spots = _buildExpenseSpots(trip.expenses);
    if (spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart,
                size: 48,
                color:
                    theme.colorScheme.primary.withAlpha((0.3 * 255).toInt())),
            const SizedBox(height: 12),
            Text(loc.get('no_data'), style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }
    // Raggruppa per giorno e prendi gli ultimi 15 giorni
    final Map<DateTime, double> dailyTotals = {};
    for (final e in trip.expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + (e.amount ?? 0);
    }
    final sortedDays = dailyTotals.keys.toList()..sort();
    final last15 = sortedDays.length > 15
        ? sortedDays.sublist(sortedDays.length - 15)
        : sortedDays;
    // Costruisci le barGroups per il grafico
    final bars = List.generate(last15.length, (i) {
      final day = last15[i];
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: dailyTotals[day]!,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withAlpha((0.7 * 255).toInt()),
              theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ]);
    });
    final total = bars.fold<double>(0, (sum, b) => sum + b.barRods.first.toY);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up,
                  color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 8),
              Text(loc.get('expenses_trend_title'),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(loc.get('expenses_trend_desc'),
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withAlpha((0.7 * 255).toInt()))),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      theme.colorScheme.primary.withAlpha((0.07 * 255).toInt()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary
                                .withAlpha((0.7 * 255).toInt()),
                            theme.colorScheme.primary
                                .withAlpha((0.2 * 255).toInt()),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(loc.get('expenses_trend_legend'),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      barGroups: bars,
                      alignment: BarChartAlignment.spaceBetween,
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20,
                          getDrawingHorizontalLine: (value) => FlLine(
                              color: theme.dividerColor, strokeWidth: 0.5)),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                    value == 0 ? '' : value.toStringAsFixed(0),
                                    style: theme.textTheme.bodySmall);
                              }),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 ||
                                  value.toInt() >= last15.length) {
                                return const SizedBox.shrink();
                              }
                              final day = last15[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('${day.day}/${day.month}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500)),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (group.x < 0 || group.x >= last15.length) {
                              return null;
                            }
                            final day = last15[group.x.toInt()];
                            final amount = dailyTotals[day] ?? 0;
                            return BarTooltipItem(
                              '${loc.get('expenses_trend_tooltip_amount', params: {
                                    'amount': amount.toStringAsFixed(2),
                                    'currency': trip.currency
                                  })}\n${loc.get('expenses_trend_tooltip_date', params: {
                                    'day': day.day.toString(),
                                    'month': day.month.toString(),
                                    'year': day.year.toString()
                                  })}',
                              theme.textTheme.bodySmall!.copyWith(),
                            );
                          },
                        ),
                      ),
                      minY: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  loc.get('total_last_expenses',
                      params: {'n': last15.length.toString()}),
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withAlpha((0.7 * 255).toInt()))),
              const SizedBox(width: 8),
              Text('${trip.currency} ${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                      // fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
