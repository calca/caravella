import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/trip.dart';
import '../data/trips_storage.dart';
import '../widgets/caravella_bottom_bar.dart';
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

class TripSection extends StatelessWidget {
  final Trip? currentTrip;
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
        final double bottomBarHeight = 80;
        final double availableWidth = media.size.width - horizontalPadding;
        final double availableHeight =
            constraints.maxHeight - bottomBarHeight - verticalSpacing - 8;
        final double cardWidth =
            (availableWidth - 12) / 2; // 12 è lo spacing tra le due card
        final double cardSize = [
          cardWidth,
          (availableHeight - verticalSpacing) / 2
        ].reduce((a, b) => a < b ? a : b);

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (currentTrip != null)
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 4),
                child: SizedBox(
                  height: cardSize * 2 + verticalSpacing,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: cardWidth,
                              height: cardSize,
                              child: TodaySpentCard(trip: currentTrip!)),
                          SizedBox(width: 12),
                          SizedBox(
                              width: cardWidth,
                              height: cardSize,
                              child:
                                  TopPaidByCard(trip: currentTrip!, loc: loc)),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: cardWidth,
                              height: cardSize,
                              child:
                                  WeekChartCard(trip: currentTrip!, loc: loc)),
                          SizedBox(width: 12),
                          SizedBox(
                              width: cardWidth,
                              height: cardSize,
                              child:
                                  CategoryCard(trip: currentTrip!, loc: loc)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CaravellaBottomBar(
                loc: loc,
                onTripAdded: onTripAdded,
                currentTrip: currentTrip,
              ),
            ),
          ],
        );
      },
    );
  }
}
