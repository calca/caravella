import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../trips_storage.dart';
import '../state/locale_notifier.dart';

class CurrentTripCard extends StatelessWidget {
  final Trip trip;
  final double opacity;
  const CurrentTripCard({super.key, required this.trip, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 1 / 3,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Titolo viaggio in alto, bold, allineato a sinistra
            Text(
              trip.title.isNotEmpty
                  ? trip.title[0].toUpperCase() + trip.title.substring(1)
                  : '',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            // Totale speso, grandezza H1, sempre centrato
            Center(
              child: Text(
                '€ ${trip.expenses.fold<double>(0, (sum, s) => sum + s.amount).toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Numero partecipanti, allineato a sinistra
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.people,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 4),
                Text('${trip.participants.length} ${loc.get('participants')}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            // Data inizio e fine sulla stessa riga, allineata a sinistra
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${loc.get('from_to', params: {
                        'start':
                            '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                        'end':
                            '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}'
                      })}',
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
