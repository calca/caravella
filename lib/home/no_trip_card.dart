import 'package:flutter/material.dart';
import '../app_localizations.dart';

class NoTripCard extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onAddTrip;
  final double opacity;
  const NoTripCard({super.key, required this.loc, required this.onAddTrip, required this.opacity});

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.get('no_trips_found'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(loc.get('add_trip')),
              onPressed: onAddTrip,
            ),
          ],
        ),
      ),
    );
  }
}
