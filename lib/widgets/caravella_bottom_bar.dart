import 'package:flutter/material.dart';
import 'package:org_app_caravella/trip/add_expense_component.dart';
import '../data/trip.dart';
import '../trip/history_page.dart';
import '../app_localizations.dart';
import '../data/trips_storage.dart';
import '../settings/settings_page.dart';

class CaravellaBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  const CaravellaBottomBar(
      {super.key,
      required this.loc,
      required this.onTripAdded,
      this.currentTrip});
  final Trip? currentTrip;

  @override
  Widget build(BuildContext context) {
    // Usa SafeArea per evitare overlay con la gesture bar e padding inferiore
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.32)
                        : Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(32),
                    // Nessuna shadow per look più flat
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HistoryPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      // boxShadow rimossa per look flat
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
                            child: AddExpenseComponent(
                              participants: currentTrip!.participants,
                              categories: currentTrip!.categories,
                              onExpenseAdded: (expense) async {
                                final trips = await TripsStorage.readTrips();
                                final idx = trips
                                    .indexWhere((v) => v.id == currentTrip!.id);
                                if (idx != -1) {
                                  trips[idx].expenses.add(expense);
                                  await TripsStorage.writeTrips(trips);
                                  onTripAdded();
                                }
                              },
                              onCategoryAdded: (newCategory) async {
                                final trips = await TripsStorage.readTrips();
                                final idx = trips
                                    .indexWhere((v) => v.id == currentTrip!.id);
                                if (idx != -1) {
                                  if (!trips[idx]
                                      .categories
                                      .contains(newCategory)) {
                                    trips[idx].categories.add(newCategory);
                                    await TripsStorage.writeTrips(trips);
                                    onTripAdded();
                                  }
                                }
                              },
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
      ),
    );
  }
}
