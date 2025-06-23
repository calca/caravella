import 'package:flutter/material.dart';
import 'package:org_app_caravella/trip/add_expense_sheet.dart';
import '../trips_storage.dart';
import 'add_trip_page.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../widgets/trip_amount_card.dart';

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
    final trip = _trip;
    if (trip == null) return; // Evita null check operator su _trip
    final trips = await TripsStorage.readTrips();
    final idx = trips.indexWhere((v) =>
        v.title == trip.title &&
        v.startDate == trip.startDate &&
        v.endDate == trip.endDate);
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
            // Card con info viaggio e totale speso
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} - ${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '${loc.get('participants')}: ${trip.participants.join(", ")}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${trip.currency} ${trip.expenses.fold<double>(0, (sum, s) => sum + s.amount).toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(loc.get('total_spent'),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                      tabs: [
                        Tab(text: loc.get('expenses')),
                        Tab(text: 'Overview'),
                        Tab(text: 'Statistiche'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Spese
                          trip.expenses.isEmpty
                              ? Center(child: Text(loc.get('no_expenses')))
                              : ListView.builder(
                                  itemCount: trip.expenses.length,
                                  itemBuilder: (context, i) {
                                    final expense = trip.expenses[i];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      child: TripAmountCard(
                                        title: expense.description,
                                        coins: expense.amount.toInt(),
                                        checked: true,
                                        paidBy: expense.paidBy,
                                        category: null,
                                        date: expense.date,
                                        currency: trip.currency,
                                      ),
                                    );
                                  },
                                ),
                          // Tab 2: Overview
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListView(
                              children: [
                                Text('Spese per partecipante',
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                ...trip.participants.map((p) {
                                  final total = trip.expenses
                                      .where((e) => e.paidBy == p)
                                      .fold<double>(0, (sum, e) => sum + e.amount);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(p, style: Theme.of(context).textTheme.bodyMedium),
                                        Text('${trip.currency} ${total.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 18),
                                Text('Spese per categoria',
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                ...trip.categories.map((cat) {
                                  final total = trip.expenses
                                      .where((e) => e.description == cat)
                                      .fold<double>(0, (sum, e) => sum + e.amount);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(cat, style: Theme.of(context).textTheme.bodyMedium),
                                        Text('${trip.currency} ${total.toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  );
                                }),
                                // Mostra eventuali spese senza categoria
                                if (trip.expenses.any((e) => e.description.isEmpty || !trip.categories.contains(e.description)))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('—', style: Theme.of(context).textTheme.bodyMedium),
                                        Text(
                                          '${trip.currency} ${trip.expenses.where((e) => e.description.isEmpty || !trip.categories.contains(e.description)).fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Tab 3: Statistiche (placeholder)
                          Center(child: Text('Statistiche')), // TODO: contenuto reale
                        ],
                      ),
                    ),
                  ],
                ),
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
                      categories: trip.categories,
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
                      onCategoryAdded: (newCategory) async {
                        final trips = await TripsStorage.readTrips();
                        final idx = trips.indexWhere((v) =>
                            v.title == trip.title &&
                            v.startDate == trip.startDate &&
                            v.endDate == trip.endDate);
                        if (idx != -1) {
                          if (!trips[idx].categories.contains(newCategory)) {
                            trips[idx].categories.add(newCategory);
                            await TripsStorage.writeTrips(trips);
                            await _refreshTrip();
                          }
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
