import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/trip.dart';
import '../../state/locale_notifier.dart';

class CurrentTripCard extends StatelessWidget {
  final Trip trip;
  final double opacity;
  const CurrentTripCard({super.key, required this.trip, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            trip.title.isNotEmpty
                ? trip.title[0].toUpperCase() + trip.title.substring(1)
                : '',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  trip.expenses
                      .fold<double>(0, (sum, s) => sum + (s.amount ?? 0))
                      .toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 4),
                Text(
                  trip.currency,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22, // più piccolo dell'amount
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.people, color: Theme.of(context).colorScheme.onSurface, size: 20),
              const SizedBox(width: 4),
              Text('${trip.participants.length} ${loc.get('participants')}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface, size: 20),
              const SizedBox(width: 4),
              Text(
                loc.get('from_to', params: {
                  'start':
                      '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                  'end':
                      '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}'
                }),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
