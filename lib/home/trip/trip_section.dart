import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/trip.dart';
import 'cards/today_spent_card.dart';
import 'cards/top_paid_by_card.dart';
import 'cards/week_chart_card.dart';
import 'cards/category_card.dart';

// Estensione per controllare se una data è oggi
extension DateTimeToday on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

class TripSection extends StatelessWidget {
  final Trip currentTrip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  static const double sectionOpacity = 1;

  const TripSection({
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
        final double verticalSpacing = 12;
        final double availableWidth = media.size.width - horizontalPadding;
        final double availableHeight =
            constraints.maxHeight - 16; // padding per il layout
        final double cardWidth =
            (availableWidth - 12) / 2; // 12 è lo spacing tra le due card

        // Calculate the maximum possible card height based on available space
        final double maxCardHeight = (availableHeight - verticalSpacing) / 2;

        // Only apply minimum if we have enough space, otherwise use what's available
        final double cardHeight = maxCardHeight > 100.0
            ? math.max(100.0, maxCardHeight)
            : math.max(80.0, maxCardHeight);

        final double cardSize = math.min(cardWidth, cardHeight);

        // If available height is too small, make it scrollable
        if (availableHeight < 200) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: cardWidth,
                          height:
                              100.0, // Fixed smaller height for scrollable view
                          child: TodaySpentCard(trip: currentTrip)),
                      SizedBox(width: 12),
                      SizedBox(
                          width: cardWidth,
                          height: 100.0,
                          child: TopPaidByCard(trip: currentTrip, loc: loc)),
                    ],
                  ),
                  SizedBox(height: verticalSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: cardWidth,
                          height: 100.0,
                          child: WeekChartCard(trip: currentTrip, loc: loc)),
                      SizedBox(width: 12),
                      SizedBox(
                          width: cardWidth,
                          height: 100.0,
                          child: CategoryCard(trip: currentTrip, loc: loc)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: cardWidth,
                          height: cardSize,
                          child: TodaySpentCard(trip: currentTrip)),
                      SizedBox(width: 12),
                      SizedBox(
                          width: cardWidth,
                          height: cardSize,
                          child: TopPaidByCard(trip: currentTrip, loc: loc)),
                    ],
                  ),
                  SizedBox(height: verticalSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: cardWidth,
                          height: cardSize,
                          child: WeekChartCard(trip: currentTrip, loc: loc)),
                      SizedBox(width: 12),
                      SizedBox(
                          width: cardWidth,
                          height: cardSize,
                          child: CategoryCard(trip: currentTrip, loc: loc)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
