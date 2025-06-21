import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../trips_storage.dart';
import 'top_card_box_decoration.dart';

class CurrentTripCard extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  final double opacity;
  const CurrentTripCard({super.key, required this.trip, required this.loc, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return TopCardBoxDecoration(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              trip.title.isNotEmpty
                  ? trip.title[0].toUpperCase() + trip.title.substring(1)
                  : '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '€ ${trip.expenses.fold<double>(0, (sum, s) => sum + s.amount).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.people, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 4),
                Text('${trip.participants.length} ${loc.get('participants')}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 4),
                Text('dal ${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} al ${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
