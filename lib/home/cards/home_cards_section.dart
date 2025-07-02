import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/expense_group.dart';
import 'home_cards_header.dart';
import '../../widgets/caravella_bottom_bar.dart';

class HomeCardsSection extends StatelessWidget {
  final ExpenseGroup trip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;

  const HomeCardsSection({
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
                    child: HomeCardsHeader(trip: trip),
                  ),
                ),

                // Spazio flessibile tra header e cards
                SizedBox(
                  height: isSmallScreen ? 4 : (isMediumScreen ? 8 : 12),
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
