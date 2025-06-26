import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import 'top_card_box_decoration.dart';

class NoTripCard extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onAddTrip;
  final double opacity;
  const NoTripCard(
      {super.key,
      required this.loc,
      required this.onAddTrip,
      required this.opacity});

  @override
  Widget build(BuildContext context) {
    return TopCardBoxDecoration(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.get('no_trips_found'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w300, // light
                    color: Colors.white, // testo bianco
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
    );
  }
}
