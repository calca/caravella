import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/trip.dart';
import '../../state/locale_notifier.dart';

class HomeTripCard extends StatelessWidget {
  final Trip trip;
  const HomeTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 32), // Spazio extra in alto
          // Totale spese a sinistra, con spazio sopra e sotto
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  trip.expenses
                      .fold<double>(0, (sum, s) => sum + (s.amount ?? 0))
                      .truncate()
                      .toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 54, // font più grande
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  trip.currency,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                      ),
                ),
              ],
            ),
          ),
          // Titolo viaggio a destra
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  trip.title.isNotEmpty
                      ? trip.title[0].toUpperCase() + trip.title.substring(1)
                      : '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Partecipanti a destra
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${trip.participants.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 4),
              Icon(Icons.people,
                  color: Theme.of(context).colorScheme.onSurface, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          // Date viaggio a destra
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 4),
              Icon(Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurface, size: 20),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
