import 'package:flutter/material.dart';
import 'package:org_app_caravella/trip/add_expense_sheet.dart';
import 'trips_storage.dart';
import 'add_trip_page.dart';
import 'app_localizations.dart';
import 'state/locale_notifier.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  Trip? _trip;
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    final trips = await TripsStorage.readTrips();
    final idx = trips.indexWhere(
      (t) =>
          t.title == widget.trip.title &&
          t.startDate == widget.trip.startDate &&
          t.endDate == widget.trip.endDate,
    );
    setState(() {
      _trip = idx != -1 ? trips[idx] : null;
      _deleted = idx == -1;
    });
    if (_deleted && mounted) {
      Navigator.of(context).pop(true); // Torna in home e aggiorna
    }
  }

  Future<void> _refreshTrip() async {
    final trips = await TripsStorage.readTrips();
    final idx = trips.indexWhere((v) =>
        v.title == _trip!.title &&
        v.startDate == _trip!.startDate &&
        v.endDate == _trip!.endDate);
    if (idx != -1) {
      setState(() {
        _trip = trips[idx];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }
    final trip = _trip;
    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: loc.get('edit'),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTripPage(
                      trip: trip,
                      onTripDeleted: () async {
                        await _loadTrip();
                      }),
                ),
              );
              if (result == true && context.mounted) {
                await _refreshTrip();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.get('period', params: {
                'start':
                    '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                'end':
                    '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}'
              }),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${loc.get('participants')}: ${trip.participants.join(", ")}'),
            const SizedBox(height: 16),
            Text('${loc.get('expenses')}:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: trip.expenses.isEmpty
                  ? Text(loc.get('no_expenses'))
                  : ListView.builder(
                      itemCount: trip.expenses.length,
                      itemBuilder: (context, i) {
                        final expense = trip.expenses[i];
                        return ListTile(
                          title: Text(expense.description),
                          subtitle: Text(
                              '${loc.get('paid_by')}: ${expense.paidBy}\n${loc.get('date')}: ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                          trailing:
                              Text('€${expense.amount.toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(loc.get('add_expense')),
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
                            v.endDate == trip.endDate);
                        if (idx != -1) {
                          trips[idx].expenses.add(expense);
                          await TripsStorage.writeTrips(trips);
                          await _refreshTrip();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
