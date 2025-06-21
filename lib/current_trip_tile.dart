import 'package:flutter/material.dart';
import 'trip_detail_page.dart';
import 'trips_storage.dart';
import 'app_localizations.dart';
import 'add_trip_page.dart';

class CurrentTripTile extends StatelessWidget {
  final AppLocalizations localizations;
  final VoidCallback? onTripAdded;
  const CurrentTripTile({super.key, required this.localizations, this.onTripAdded});

  Future<Trip?> _getCurrentTrip() async {
    final trips = await TripsStorage.readTrips();
    if (trips.isEmpty) return null;
    trips.sort((a, b) => b.startDate.compareTo(a.startDate));
    return trips.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Trip?>(
      future: _getCurrentTrip(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final trip = snapshot.data;
        if (trip == null) {
          return FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      localizations.get('no_trips_found'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddTripPage(
                            localizations: localizations,
                            onTripDeleted: onTripAdded, // callback per refresh dopo delete
                          ),
                        ),
                      );
                      if (result == true && onTripAdded != null) onTripAdded!();
                    },
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final totalAmount = trip.expenses.fold<double>(0, (sum, s) => sum + s.amount);
        return FractionallySizedBox(
          widthFactor: 0.8,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TripDetailPage(trip: trip, localizations: localizations),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.get('total_spent'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '\u20ac ${totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 32),
                            tooltip: localizations.get('add_expense'),
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
                                    participants: trip.participants,
                                    onExpenseAdded: (expense) async {
                                      final trips = await TripsStorage.readTrips();
                                      final idx = trips.indexWhere((v) =>
                                        v.title == trip.title &&
                                        v.startDate == trip.startDate &&
                                        v.endDate == trip.endDate
                                      );
                                      if (idx != -1) {
                                        trips[idx].expenses.add(expense);
                                        await TripsStorage.writeTrips(trips); // Salva su file JSON
                                        if (onTripAdded != null) onTripAdded!(); // Aggiorna la home
                                      }
                                    },
                                    localizations: localizations,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
