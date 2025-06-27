import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/trip.dart';
import '../../../app_localizations.dart';
import '../../../widgets/currency_display.dart';
import '../../../state/locale_notifier.dart';

class StatisticsTab extends StatelessWidget {
  final Trip trip;

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
          _buildDailyExpensesChart(context, dailyStats, loc),

          const SizedBox(height: 32),

          // Statistiche generali
          _buildGeneralStats(context, loc),
        ],
      ),
    );
  }

  Map<DateTime, double> _calculateDailyStats() {
    final stats = <DateTime, double>{};

    // Inizializza tutti i giorni del viaggio con 0
    DateTime currentDate =
        DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final endDate =
        DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);

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
        stats[expenseDate] = (stats[expenseDate] ?? 0) + expense.amount!;
      }
    }

    return stats;
  }

  Widget _buildDailyExpensesChart(BuildContext context,
      Map<DateTime, double> dailyStats, AppLocalizations loc) {
    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = dailyStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxAmount = dailyStats.values.reduce((a, b) => a > b ? a : b);
    final minAmount = dailyStats.values
        .where((v) => v > 0)
        .fold(double.infinity, (a, b) => a < b ? a : b);

    // Usa scala logaritmica se c'è una grande differenza tra min e max
    final useLogScale =
        maxAmount > 0 && minAmount > 0 && (maxAmount / minAmount) > 100;

    // Calcola l'altezza del grafico: max 1/3 della pagina, min 180px, max 300px
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = (screenHeight / 3).clamp(180.0, 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('daily_expenses_chart'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: chartHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width:
                  (sortedEntries.length * 60.0).clamp(300.0, double.infinity),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        useLogScale ? null : _calculateInterval(maxAmount),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value <= 0) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CurrencyDisplay(
                              value: value,
                              currency: trip.currency,
                              valueFontSize: 10,
                              currencyFontSize: 8,
                              showDecimals: false,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedEntries.length) {
                            return const SizedBox.shrink();
                          }

                          final date = sortedEntries[index].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                      bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: (sortedEntries.length - 1).toDouble(),
                  minY:
                      useLogScale ? (minAmount > 0 ? minAmount * 0.5 : 0.1) : 0,
                  maxY: useLogScale ? maxAmount * 1.5 : maxAmount * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedEntries.asMap().entries.map((entry) {
                        final value = entry.value.value;
                        final y = useLogScale && value > 0 ? value : value;
                        return FlSpot(entry.key.toDouble(), y);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).colorScheme.primary,
                            strokeColor: Theme.of(context).colorScheme.surface,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          Theme.of(context).colorScheme.inverseSurface,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= sortedEntries.length)
                            return null;

                          final date = sortedEntries[index].key;
                          final amount = sortedEntries[index].value;

                          return LineTooltipItem(
                            '${date.day}/${date.month}\n${amount.toStringAsFixed(2)} ${trip.currency}',
                            TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 0) return 1;

    final magnitude = (maxValue / 5).toString().length - 1;
    final base = [1, 2, 5][(magnitude % 3)];
    final multiplier =
        [1, 10, 100, 1000, 10000, 100000][(magnitude / 3).floor()];

    return (base * multiplier).toDouble();
  }

  Widget _buildGeneralStats(BuildContext context, AppLocalizations loc) {
    final totalAmount =
        trip.expenses.fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
    final averageAmount =
        trip.expenses.isNotEmpty ? totalAmount / trip.expenses.length : 0.0;
    final maxExpense = trip.expenses.isNotEmpty
        ? trip.expenses
            .where((e) => e.amount != null)
            .reduce((a, b) => (a.amount ?? 0) > (b.amount ?? 0) ? a : b)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('general_statistics'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        
        // Spesa media
        _buildFlatStatItem(
          context,
          loc.get('average_expense'),
          CurrencyDisplay(
            value: averageAmount,
            currency: trip.currency,
            valueFontSize: 18,
            currencyFontSize: 14,
            showDecimals: true,
          ),
        ),
        
        if (maxExpense != null) ...[
          // Spesa più alta
          _buildFlatStatItem(
            context,
            'Maggiore spesa: ${maxExpense.category.isNotEmpty ? maxExpense.category : loc.get('uncategorized')}',
            CurrencyDisplay(
              value: maxExpense.amount ?? 0,
              currency: trip.currency,
              valueFontSize: 18,
              currencyFontSize: 14,
              showDecimals: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFlatStatItem(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          content,
        ],
      ),
    );
  }
}
