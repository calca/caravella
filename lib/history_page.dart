import 'package:flutter/material.dart';
import 'trips_storage.dart';
import 'trip_detail_page.dart';
import 'app_localizations.dart';

class HistoryPage extends StatefulWidget {
  final AppLocalizations localizations;
  const HistoryPage({super.key, required this.localizations});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Trip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = TripsStorage.readTrips();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localizations;
    return Scaffold(
      appBar: AppBar(title: Text(loc.get('trip_history'))),
      body: FutureBuilder<List<Trip>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(loc.get('no_trips_found')));
          }
          final trips = snapshot.data!;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(trip.title),
                  subtitle: Text(
                    "${loc.get('from_to', params: {
                      'start': '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                      'end': '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}'
                    })}\n${loc.get('participants')}: ${trip.participants.join(", ")}",
                  ),
                  trailing: Text(
                    "${loc.get('expenses')}: ${trip.expenses.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TripDetailPage(trip: trip, localizations: widget.localizations),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
