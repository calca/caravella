import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/trip.dart';
import 'bottom_card/today_spent_card.dart';
import 'bottom_card/top_paid_by_card.dart';
import 'bottom_card/week_chart_card.dart';
import 'bottom_card/category_card.dart';

// Estensione per controllare se una data è oggi
extension DateTimeToday on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

class HomeTripCards extends StatelessWidget {
  final Trip currentTrip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  static const double sectionOpacity = 1;

  const HomeTripCards({
    super.key,
    required this.currentTrip,
    required this.loc,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        // Padding coerente con la bottom bar (8px orizzontale)
        final double horizontalPadding = 8 * 2; // left + right
        final double availableWidth = media.size.width - horizontalPadding;
        final double availableHeight = constraints.maxHeight - 16;
        
        // Calcola l'altezza ottimale per le card mantenendole sempre uguali
        final double optimalCardHeight = math.max(
          120.0, // Altezza minima per leggibilità
          math.min(
            180.0, // Altezza massima per evitare card troppo grandi
            (availableHeight - 12) / 2, // Spazio disponibile diviso per 2 righe
          ),
        );

        // Se lo spazio è troppo piccolo, usa scroll con altezza fissa
        final bool useScrollableLayout = availableHeight < 280;
        final double cardHeight = useScrollableLayout ? 120.0 : optimalCardHeight;

        if (useScrollableLayout) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 0, bottom: 4),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: (availableWidth - 12) / 2 / cardHeight,
              children: [
                TodaySpentCard(trip: currentTrip),
                TopPaidByCard(trip: currentTrip, loc: loc),
                WeekChartCard(trip: currentTrip, loc: loc),
                CategoryCard(trip: currentTrip, loc: loc),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 4),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: (availableWidth - 12) / 2 / cardHeight,
            children: [
              TodaySpentCard(trip: currentTrip),
              TopPaidByCard(trip: currentTrip, loc: loc),
              WeekChartCard(trip: currentTrip, loc: loc),
              CategoryCard(trip: currentTrip, loc: loc),
            ],
          ),
        );
      },
    );
  }
}
