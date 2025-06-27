import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../data/trip.dart';
import '../../../app_localizations.dart';

class StatisticsTab extends StatelessWidget {
  final Trip? trip;
  const StatisticsTab({super.key, this.trip});

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
    // Raggruppa per giorno per tutti i giorni del viaggio
    final Map<DateTime, double> dailyTotals = {};
    for (final e in trip.expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + (e.amount ?? 0);
    }

    // Genera tutti i giorni del viaggio (dall'inizio alla fine)
    final startDate =
        DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final endDate =
        DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
    final allDays = <DateTime>[];
    for (var day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      allDays.add(day);
      // Assicurati che ogni giorno abbia un valore (anche 0)
      dailyTotals[day] = dailyTotals[day] ?? 0;
    }
    // Costruisci i punti per il grafico a linea con scala logaritmica
    final lineSpots = List.generate(allDays.length, (i) {
      final day = allDays[i];
      final value = dailyTotals[day]!;
      // Per la scala logaritmica, usiamo log(value + 1) per gestire i valori 0
      final logValue = value > 0 ? math.log(value).toDouble() : 0.0;
      return FlSpot(i.toDouble(), logValue);
    });

    // Trova il valore massimo per determinare l'intervallo dell'asse Y
    final maxValue = dailyTotals.values.where((v) => v > 0).isEmpty
        ? 1.0
        : dailyTotals.values.where((v) => v > 0).reduce(math.max);
    final maxLogValue = maxValue > 0 ? math.log(maxValue).toDouble() : 0.0;

    // Calcola i limiti per assicurare che tutto sia visibile
    final paddedMaxLogValue =
        maxLogValue > 0 ? maxLogValue * 1.1 : 1.0; // Aggiungiamo 10% di padding
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calcola l'altezza massima del grafico (1/3 della pagina)
          final maxChartHeight = constraints.maxHeight / 3;
          final chartHeight = math.min(maxChartHeight, 240.0); // Max 240px

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up,
                      color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(loc.get('expenses_trend_title'),
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Grafico con altezza fissa e limitata
              SizedBox(
                height: chartHeight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: allDays.length *
                        40.0, // 40 pixel per giorno per dare spazio
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: theme.colorScheme.surface,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary
                                      .withAlpha((0.3 * 255).toInt()),
                                  theme.colorScheme.primary
                                      .withAlpha((0.05 * 255).toInt()),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: paddedMaxLogValue > 3
                                ? paddedMaxLogValue / 5
                                : 1, // Intervallo dinamico
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                                color: theme.dividerColor, strokeWidth: 0.5),
                            getDrawingVerticalLine: (value) => FlLine(
                                color: theme.dividerColor
                                    .withAlpha((0.3 * 255).toInt()),
                                strokeWidth: 0.5)),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: paddedMaxLogValue > 3
                                    ? paddedMaxLogValue / 4
                                    : 1, // Intervallo dinamico per le etichette
                                getTitlesWidget: (value, meta) {
                                  if (value <= 0)
                                    return const SizedBox.shrink();
                                  // Converti il valore logaritmico al valore reale
                                  final realValue = math.exp(value);
                                  if (realValue < 1)
                                    return const SizedBox.shrink();
                                  return Text(realValue.toStringAsFixed(0),
                                      style: theme.textTheme.bodySmall);
                                }),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < 0 ||
                                    value.toInt() >= allDays.length) {
                                  return const SizedBox.shrink();
                                }
                                final day = allDays[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('${day.day}/${day.month}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots
                                  .map((LineBarSpot touchedSpot) {
                                if (touchedSpot.x < 0 ||
                                    touchedSpot.x >= allDays.length) {
                                  return null;
                                }
                                final day = allDays[touchedSpot.x.toInt()];
                                // Mostra il valore reale, non quello logaritmico
                                final amount = dailyTotals[day] ?? 0;
                                return LineTooltipItem(
                                  '${loc.get('expenses_trend_tooltip_amount', params: {
                                        'amount': amount.toStringAsFixed(2),
                                        'currency': trip.currency
                                      })}\n${loc.get('expenses_trend_tooltip_date', params: {
                                        'day': day.day.toString(),
                                        'month': day.month.toString(),
                                        'year': day.year.toString()
                                      })}',
                                  theme.textTheme.bodySmall!
                                      .copyWith(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        minY: 0,
                        maxY: paddedMaxLogValue,
                      ),
                    ),
                  ),
                ),
              ),
              // Spazio aggiuntivo sotto il grafico per eventuali contenuti futuri
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
