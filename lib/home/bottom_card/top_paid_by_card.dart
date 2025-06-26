import 'package:flutter/material.dart';
import '../../data/trip.dart';
import 'base_flat_card.dart';
import '../../trip/detail_page/trip_detail_page.dart';
import '../../app_localizations.dart';

class TopPaidByCard extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  const TopPaidByCard({required this.trip, required this.loc, super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totals = {};
    for (final e in trip.expenses) {
      totals[e.paidBy] = (totals[e.paidBy] ?? 0) + (e.amount ?? 0);
    }
    final top = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return BaseFlatCard(
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
              loc.get('people'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Spacer(),
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
      ),
    );
  }
}
