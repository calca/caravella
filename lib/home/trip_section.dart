import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../trips_storage.dart';
import 'trip_expenses_list.dart';
import 'caravella_bottom_bar.dart';
import '../trip/trip_detail_page.dart';

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
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: sectionOpacity),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                if (currentTrip != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 28, left: 16, right: 16, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.get('latest_expenses'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          tooltip: loc.get('trip_detail'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripDetailPage(trip: currentTrip!),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                if (currentTrip == null)
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/home/no_travels.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  TripExpensesList(currentTrip: currentTrip, loc: loc),
                const SizedBox(height: 64), // Spazio per la bottom bar
              ],
            ),
          ),
        ),
        // CaravellaBottomBar sopra la lista, trasparente e con shadow
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            // Nessun bordo, nessun blur, nessun bordo arrotondato
            color: Colors.transparent,
            child: CaravellaBottomBar(
              loc: loc,
              onTripAdded: onTripAdded,
              currentTrip: currentTrip,
            ),
          ),
        ),
      ],
    );
  }
}
