import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/expense_group.dart';
import '../../../../app_localizations.dart';

class DailyExpensesChart extends StatelessWidget {
  final ExpenseGroup trip;
  final Map<DateTime, double> dailyStats;
  final AppLocalizations loc;

  const DailyExpensesChart({
    super.key,
    required this.trip,
    required this.dailyStats,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = dailyStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Trova l'ultimo giorno con spese > 0
    int lastDayWithExpenses = sortedEntries.length - 1;
    for (int i = sortedEntries.length - 1; i >= 0; i--) {
      if (sortedEntries[i].value > 0) {
        lastDayWithExpenses = i;
        break;
      }
    }

    // Filtra per mostrare solo dall'inizio fino all'ultimo giorno con spese
    final filteredEntries =
        sortedEntries.take(lastDayWithExpenses + 1).toList();

    if (filteredEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxAmount =
        filteredEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minAmount = filteredEntries
        .map((e) => e.value)
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
              width: _calculateChartWidth(context, filteredEntries.length),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: false, // Rimuove tutte le righe orizzontali
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= filteredEntries.length) {
                            return const SizedBox.shrink();
                          }

                          final date = filteredEntries[index].key;
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
                      bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: (filteredEntries.length - 1).toDouble(),
                  minY:
                      useLogScale ? (minAmount > 0 ? minAmount * 0.5 : 0.1) : 0,
                  maxY:
                      useLogScale ? maxAmount * 1.5 : _calculateMaxY(maxAmount),
                  lineBarsData: [
                    LineChartBarData(
                      spots: filteredEntries.asMap().entries.map((entry) {
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
                          if (index < 0 || index >= filteredEntries.length) {
                            return null;
                          }

                          final date = filteredEntries[index].key;
                          final amount = filteredEntries[index].value;

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
    if (maxValue <= 0) return 100;

    // Calcola un intervallo per avere esattamente 4 divisioni
    if (maxValue <= 200) return 50; // 0, 50, 100, 150, 200
    if (maxValue <= 400) return 100; // 0, 100, 200, 300, 400
    if (maxValue <= 800) return 200; // 0, 200, 400, 600, 800
    if (maxValue <= 1000) return 250; // 0, 250, 500, 750, 1000
    if (maxValue <= 2000) return 500; // 0, 500, 1000, 1500, 2000

    // Per valori maggiori, usa 1000
    return 1000;
  }

  double _calculateMaxY(double maxValue) {
    if (maxValue <= 0) return 200;

    final interval = _calculateInterval(maxValue);

    // Trova il primo multiplo dell'intervallo che supera il valore massimo
    final numberOfIntervals = (maxValue / interval).ceil();

    // Usa esattamente quello che serve
    return numberOfIntervals * interval;
  }

  double _calculateChartWidth(BuildContext context, int numberOfDays) {
    final screenWidth = MediaQuery.of(context).size.width;
    const minDaysVisible = 15;
    const padding = 32.0; // Padding laterale del SingleChildScrollView

    final availableWidth = screenWidth - padding;

    if (numberOfDays <= minDaysVisible) {
      // Se ci sono 15 giorni o meno, usa tutta la larghezza disponibile
      return availableWidth;
    } else {
      // Se ci sono più di 15 giorni, calcola la larghezza per mostrare esattamente 15 giorni inizialmente
      final widthPerDay = availableWidth / minDaysVisible;
      return widthPerDay * numberOfDays;
    }
  }
}
