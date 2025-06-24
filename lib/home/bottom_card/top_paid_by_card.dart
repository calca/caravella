import 'package:flutter/material.dart';
import '../../trips_storage.dart';
import 'base_flat_card.dart';

class TopPaidByCard extends StatelessWidget {
  final Trip trip;
  const TopPaidByCard({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totals = {};
    for (final e in trip.expenses) {
      totals[e.paidBy] = (totals[e.paidBy] ?? 0) + e.amount;
    }
    final top = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return BaseFlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top pagatori', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          if (top.isEmpty)
            Text('-', style: Theme.of(context).textTheme.titleLarge)
          else
            ...top.take(2).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(e.key,
                              style: Theme.of(context).textTheme.bodyMedium)),
                      Text('${trip.currency} ${e.value.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
