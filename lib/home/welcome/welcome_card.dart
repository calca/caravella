import 'package:flutter/material.dart';
import '../../app_localizations.dart';

class WelcomeCard extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onAddTrip;
  final double opacity;
  const WelcomeCard(
      {super.key,
      required this.loc,
      required this.onAddTrip,
      required this.opacity});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                loc.get('no_trips_found'),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(loc.get('add_trip')),
                onPressed: onAddTrip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
