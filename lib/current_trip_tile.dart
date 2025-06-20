import 'package:flutter/material.dart';
import 'trip_detail_page.dart';
import 'trips_storage.dart';

class CurrentTripTile extends StatelessWidget {
  const CurrentTripTile({super.key});

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
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text('No trip found', style: TextStyle(fontSize: 18)),
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
                      builder: (context) => TripDetailPage(trip: trip),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                      const Text(
                        'Total spent:',
                        style: TextStyle(
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
                            tooltip: 'Add expense',
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
