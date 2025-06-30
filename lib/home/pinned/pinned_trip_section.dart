import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/trip.dart';
import '../../../trip/detail_page/trip_detail_page.dart';
import '../trip/home_trip_header.dart';

class PinnedTripSection extends StatelessWidget {
  final Trip pinnedTrip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;

  const PinnedTripSection({
    super.key,
    required this.pinnedTrip,
    required this.loc,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con titolo "Viaggio Pinnato"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.push_pin,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Viaggio Pinnato",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),

        // Card del viaggio pinnato
        GestureDetector(
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripDetailPage(trip: pinnedTrip),
              ),
            );
            if (result == true) {
              onTripAdded();
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: HomeTripCard(trip: pinnedTrip),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
