import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../trips_storage.dart';
import '../../../app_localizations.dart';

class StatisticsTab extends StatelessWidget {
  final Trip? trip;
  const StatisticsTab({super.key, this.trip});

  List<FlSpot> _buildExpenseSpots(List<Expense> expenses) {
    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));
    final last15 =
        sorted.length > 15 ? sorted.sublist(sorted.length - 15) : sorted;
    double running = 0;
    return List.generate(last15.length, (i) {
      running += last15[i].amount;
      return FlSpot(i.toDouble(), running);
    });
  }

  List<BarChartGroupData> _buildExpenseBars(
      List<Expense> expenses, Color barColor) {
    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));
    final last15 =
        sorted.length > 15 ? sorted.sublist(sorted.length - 15) : sorted;
    return List.generate(last15.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: last15[i].amount,
            color: barColor,
            borderRadius: BorderRadius.circular(4),
            width: 16,
          ),
        ],
      );
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
                size: 48, color: theme.colorScheme.primary.withAlpha((0.3 * 255).toInt())),
            const SizedBox(height: 12),
            Text(loc.get('no_data'), style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }
    final spots = _buildExpenseSpots(trip.expenses);
    final bars = _buildExpenseBars(trip.expenses, theme.colorScheme.primary);
    if (spots.isEmpty && bars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart,
                size: 48, color: theme.colorScheme.primary.withAlpha((0.3 * 255).toInt())),
            const SizedBox(height: 12),
            Text(loc.get('no_data'), style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }
    final sorted = List<Expense>.from(trip.expenses)
      ..sort((a, b) => a.date.compareTo(b.date));
    final last15 =
        sorted.length > 15 ? sorted.sublist(sorted.length - 15) : sorted;
    final total = last15.fold<double>(0, (sum, e) => sum + e.amount);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.get('expenses_trend_title'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(loc.get('expenses_trend_desc'),
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((0.06 * 255).toInt()),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(loc.get('expenses_trend_legend'),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      barGroups: bars,
                      alignment: BarChartAlignment.spaceBetween,
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 ||
                                  value.toInt() >= last15.length) {
                                return const SizedBox.shrink();
                              }
                              final day = last15[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('${day.day}/${day.month}',
                                    style: theme.textTheme.bodySmall),
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
                          tooltipBgColor: theme.colorScheme.surface,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (group.x < 0 || group.x >= last15.length) {
                              return null;
                            }
                            final e = last15[group.x];
                            return BarTooltipItem(
                              '${e.amount.toStringAsFixed(2)} ${trip.currency}\n${e.date.day}/${e.date.month}/${e.date.year}',
                              theme.textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  loc.get('total_last_expenses',
                      params: {'n': last15.length.toString()}),
                  style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              Text('${trip.currency} ${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
