import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../data/expense_group.dart';
import '../../manager/detail_page/trip_detail_page.dart';
import '../trip/home_trip_header.dart';
import '../../../widgets/caravella_bottom_bar.dart';

class PinnedTripSection extends StatelessWidget {
  final ExpenseGroup pinnedTrip;
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
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.85, // Manteniamo consistenza con altre sezioni
      child: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header con titolo "Viaggio Pinnato"
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: HomeTripCard(trip: pinnedTrip),
                  ),
                ),

                // Spazio per il bottom bar
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Bottom bar posizionato in basso
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CaravellaBottomBar(
                loc: loc,
                onTripAdded: onTripAdded,
                currentTrip: pinnedTrip,
                showLeftButtons: true,
                showAddButton: true,
                animationDuration: const Duration(milliseconds: 600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
