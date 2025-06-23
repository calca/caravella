import 'package:flutter/material.dart';
import '../../../trips_storage.dart';

class OverviewTab extends StatelessWidget {
  final Trip trip;
  const OverviewTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView(
        children: [
          Text('Spese per partecipante',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...trip.participants.map((p) {
            final total = trip.expenses
                .where((e) => e.paidBy == p)
                .fold<double>(0, (sum, e) => sum + e.amount);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p, style: Theme.of(context).textTheme.bodyMedium),
                  Text('${trip.currency} ${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          Text('Spese per categoria',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...trip.categories.map((cat) {
            final total = trip.expenses
                .where((e) => e.description == cat)
                .fold<double>(0, (sum, e) => sum + e.amount);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cat, style: Theme.of(context).textTheme.bodyMedium),
                  Text('${trip.currency} ${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }),
          if (trip.expenses.any((e) =>
              e.description.isEmpty ||
              !trip.categories.contains(e.description)))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('—', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    '${trip.currency} ${trip.expenses.where((e) => e.description.isEmpty || !trip.categories.contains(e.description)).fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
