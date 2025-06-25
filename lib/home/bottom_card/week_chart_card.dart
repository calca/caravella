import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../trips_storage.dart';
import 'base_flat_card.dart';
import '../../trip/detail_page/trip_detail_page.dart';
import '../../app_localizations.dart';

class WeekChartCard extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  const WeekChartCard({required this.trip, required this.loc, super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final data = List.generate(7, (i) {
      final d = days[i];
      final total = trip.expenses
          .where((e) =>
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
      return total;
    });
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    return BaseFlatCard(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripDetailPage(trip: trip),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.get('last_week'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    7,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: maxValue > 0 ? data[i] / maxValue : 0,
                          color: Theme.of(context).colorScheme.primary,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > 6) {
                            return const SizedBox.shrink();
                          }
                          final d = days[value.toInt()];
                          return Text('${d.day}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
