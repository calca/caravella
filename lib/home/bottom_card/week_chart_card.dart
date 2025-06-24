import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../trips_storage.dart';
import 'base_flat_card.dart';
import '../../trip/detail_page/trip_detail_page.dart';

class WeekChartCard extends StatelessWidget {
  final Trip trip;
  const WeekChartCard({required this.trip, super.key});

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
          .fold<double>(0, (sum, e) => sum + e.amount);
      return total;
    });
    return BaseFlatCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(trip: trip),
          ),
        );
      },
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ultimi 7 giorni', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(
            height: 60,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                    7,
                    (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                                toY: data[i],
                                color: Theme.of(context).colorScheme.primary,
                                width: 10)
                          ],
                        )),
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
                        if (value < 0 || value > 6)
                          return const SizedBox.shrink();
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
