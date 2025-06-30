import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/trip.dart';
import 'home_trip_header.dart';
import '../../widgets/caravella_bottom_bar.dart';

class HomeTripSection extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;

  const HomeTripSection({
    super.key,
    required this.trip,
    required this.loc,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 900;

    return SizedBox(
      height:
          screenHeight * 0.85, // Manteniamo l'altezza del container principale
      child: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            // Rendiamo l'intera colonna scrollabile
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  child: Center(
                    child: HomeTripCard(trip: trip),
                  ),
                ),

                // Spazio flessibile tra header e cards
                SizedBox(
                  height: isSmallScreen ? 4 : (isMediumScreen ? 8 : 12),
                ),

                // Area centrale - placeholder per future funzionalità
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      'Area viaggio - Contenuto in sviluppo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                ),

                // Spazio inferiore flessibile
                SizedBox(
                  height: isSmallScreen ? 4 : (isMediumScreen ? 8 : 12),
                ),

                // Bottom bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: CaravellaBottomBar(
                    loc: loc,
                    onTripAdded: onTripAdded,
                    currentTrip: trip,
                    showLeftButtons: true,
                    showAddButton: true,
                    animationDuration: const Duration(milliseconds: 600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
