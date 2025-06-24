import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_localizations.dart';
import '../trips_storage.dart';
import '../widgets/caravella_bottom_bar.dart';
import 'bottom_card/today_spent_card.dart';
import 'bottom_card/top_paid_by_card.dart';
import 'bottom_card/week_chart_card.dart';
import 'bottom_card/info_card.dart';

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
        final double horizontalPadding = 12 * 2 + 12;
        final double verticalSpacing = 12;
        final double bottomBarHeight = 80;
        final double availableWidth = media.size.width - horizontalPadding;
        // Riduci leggermente lo spazio riservato alle card per lasciare più margine alla bottom bar
        final double availableHeight = constraints.maxHeight - bottomBarHeight - verticalSpacing - 8; // 8px extra margine
        final double cardSize = [
          availableWidth / 2,
          (availableHeight - verticalSpacing) / 2
        ].reduce((a, b) => a < b ? a : b);

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (currentTrip != null)
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 4), // meno spazio sotto
                child: SizedBox(
                  height: cardSize * 2 + verticalSpacing,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: cardSize,
                              height: cardSize,
                              child: TodaySpentCard(trip: currentTrip!)),
                          const SizedBox(width: 12),
                          SizedBox(
                              width: cardSize,
                              height: cardSize,
                              child: TopPaidByCard(trip: currentTrip!)),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: cardSize,
                              height: cardSize,
                              child: WeekChartCard(trip: currentTrip!)),
                          const SizedBox(width: 12),
                          SizedBox(
                              width: cardSize,
                              height: cardSize,
                              child: InfoCard()),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/home/no_travels.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            // Spacer rimosso, la bottom bar è sempre visibile
            Padding(
              padding: const EdgeInsets.only(bottom: 2), // ulteriore margine
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
