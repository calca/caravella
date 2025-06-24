import 'package:flutter/material.dart';
import '../../trips_storage.dart';
import 'base_flat_card.dart';

class TodaySpentCard extends StatelessWidget {
  final Trip trip;
  const TodaySpentCard({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    final todayTotal = trip.expenses
        .where((e) =>
            e.date.year == DateTime.now().year &&
            e.date.month == DateTime.now().month &&
            e.date.day == DateTime.now().day)
        .fold<double>(0, (sum, e) => sum + e.amount);
    return BaseFlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Speso oggi', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            '${trip.currency} ${todayTotal.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
