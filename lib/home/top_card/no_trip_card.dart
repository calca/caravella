import 'package:flutter/material.dart';
import '../../app_localizations.dart';

class NoTripCard extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onAddTrip;
  final double opacity;
  const NoTripCard({super.key, required this.loc, required this.onAddTrip, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45, // più grande
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0), // completamente trasparente
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25), // ombra nera più visibile
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.get('no_trips_found'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900, // bold importante
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
