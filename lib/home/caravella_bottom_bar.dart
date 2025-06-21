import 'package:flutter/material.dart';
import '../history_page.dart';
import '../settings_page.dart';
import '../app_localizations.dart';
import '../trip_detail_page.dart';
import '../trips_storage.dart';

class CaravellaBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  const CaravellaBottomBar({super.key, required this.loc, required this.onTripAdded, this.currentTrip});
  final Trip? currentTrip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Due container separati: uno a sinistra, uno a destra
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sinistra: history + settings
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HistoryPage(localizations: loc),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(localizations: loc),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Destra: bottone + (aggiungi spesa)
              if (currentTrip != null)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 28),
                    color: Colors.white,
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 24,
                          ),
                          child: AddExpenseSheet(
                            participants: currentTrip!.participants,
                            onExpenseAdded: (expense) async {
                              final trips = await TripsStorage.readTrips();
                              final idx = trips.indexWhere((v) =>
                                v.title == currentTrip!.title &&
                                v.startDate == currentTrip!.startDate &&
                                v.endDate == currentTrip!.endDate
                              );
                              if (idx != -1) {
                                trips[idx].expenses.add(expense);
                                await TripsStorage.writeTrips(trips);
                                onTripAdded();
                              }
                            },
                            localizations: loc,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
