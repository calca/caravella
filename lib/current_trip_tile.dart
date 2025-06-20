import 'package:flutter/material.dart';
import 'trip_detail_page.dart';
import 'trips_storage.dart';
import 'app_localizations.dart';

class CurrentTripTile extends StatelessWidget {
  final AppLocalizations localizations;
  const CurrentTripTile({super.key, required this.localizations});

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
                color: Colors.white.withAlpha(179),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(localizations.get('no_trip_found'), style: const TextStyle(fontSize: 18)),
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
                    color: Colors.white.withAlpha(179),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
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
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations.get('total_spent'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '\u20ac ${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.deepPurple, size: 32),
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
                                        await TripsStorage.writeTrips(trips);
                                        (context as Element).markNeedsBuild();
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
