import 'package:flutter/material.dart';
import '../trips_storage.dart';
import 'detail_page/trip_detail_page.dart';
import '../app_localizations.dart';
import 'add_trip_page.dart';
import '../state/locale_notifier.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Trip> _allTrips = [];
  List<Trip> _filteredTrips = [];
  String _periodFilter = 'all';
  bool _loading = true;
  final List<Map<String, dynamic>> _periodOptions = [
    {'key': 'all', 'label': 'Tutti'},
    {'key': 'last12', 'label': 'Ultimi 12 mesi'},
    {'key': 'future', 'label': 'Futuri'},
    {'key': 'past', 'label': 'Passati'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    final trips = await TripsStorage.readTrips();
    setState(() {
      _allTrips = trips;
      _filteredTrips = _applyFilter(trips);
      _loading = false;
    });
  }

  List<Trip> _applyFilter(List<Trip> trips) {
    final now = DateTime.now();
    switch (_periodFilter) {
      case 'last12':
        return trips
            .where(
                (t) => t.startDate.isAfter(now.subtract(Duration(days: 365))))
            .toList();
      case 'future':
        return trips.where((t) => t.startDate.isAfter(now)).toList();
      case 'past':
        return trips.where((t) => t.endDate.isBefore(now)).toList();
      default:
        return trips;
    }
  }

  void _onFilterChanged(String key) {
    setState(() {
      _periodFilter = key;
      _filteredTrips = _applyFilter(_allTrips);
    });
  }

  Future<void> _deleteTrip(Trip trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elimina viaggio'),
        content: Text('Vuoi davvero eliminare "${trip.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina')),
        ],
      ),
    );
    if (confirm == true) {
      _allTrips.removeWhere((t) =>
          t.title == trip.title &&
          t.startDate == trip.startDate &&
          t.endDate == trip.endDate);
      await TripsStorage.writeTrips(_allTrips);
      setState(() {
        _filteredTrips = _applyFilter(_allTrips);
      });
    }
  }

  void _showTripOptions(Trip trip) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplica'),
              onTap: () => Navigator.of(context).pop('duplicate'),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Elimina'),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      _navigateAndEditTrip(trip);
    } else if (action == 'duplicate') {
      final newTrip = Trip(
        title: "${trip.title} (Copia)",
        expenses: [],
        participants: List<String>.from(trip.participants),
        startDate: trip.startDate,
        endDate: trip.endDate,
        currency: trip.currency,
        categories: List<String>.from(trip.categories),
      );
      _allTrips.add(newTrip);
      await TripsStorage.writeTrips(_allTrips);
      setState(() {
        _filteredTrips = _applyFilter(_allTrips);
      });
    } else if (action == 'delete') {
      await _deleteTrip(trip);
    }
  }

  void _navigateAndEditTrip(Trip trip) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTripPage(trip: trip),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      final trips = await TripsStorage.readTrips();
      if (!mounted) return;
      setState(() {
        _allTrips = trips;
        _filteredTrips = _applyFilter(trips);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(loc.get('trip_history'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTripPage(),
            ),
          );
          if (result == true) {
            await _loadTrips();
          }
        },
        tooltip: loc.get('add_trip'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // FILTRI RAPIDI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periodOptions.map((opt) {
                  final selected = _periodFilter == opt['key'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(opt['label']),
                      selected: selected,
                      onSelected: (_) => _onFilterChanged(opt['key']),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _filteredTrips.isEmpty
                        ? Center(
                            key: const ValueKey('empty'),
                            child: (_periodFilter == 'all')
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/home/no_travels.png',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(loc.get('no_trips_found'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add),
                                        label: Text(loc.get('add_trip')),
                                        onPressed: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddTripPage(),
                                            ),
                                          );
                                          if (result == true) {
                                            await _loadTrips();
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          )
                        : ListView.builder(
                            key: const ValueKey('list'),
                            itemCount: _filteredTrips.length,
                            itemBuilder: (context, index) {
                              final trip = _filteredTrips[index];
                              final isFuture = trip.startDate.isAfter(now);
                              final isPast = trip.endDate.isBefore(now);
                              final total = trip.expenses
                                  .fold<double>(0, (sum, e) => sum + e.amount);
                              final badgeColor = isFuture
                                  ? Colors.blueAccent
                                  : isPast
                                      ? Colors.grey
                                      : Colors.green;
                              return Dismissible(
                                key: ValueKey(trip.title +
                                    trip.startDate.toIso8601String()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                confirmDismiss: (_) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Elimina viaggio'),
                                      content: Text(
                                          'Vuoi davvero eliminare "${trip.title}"?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Annulla')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Elimina')),
                                      ],
                                    ),
                                  );
                                  return confirm == true;
                                },
                                onDismissed: (_) => _deleteTrip(trip),
                                child: GestureDetector(
                                  onLongPress: () => _showTripOptions(trip),
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: ListTile(
                                      leading: Icon(
                                        isFuture
                                            ? Icons.schedule
                                            : isPast
                                                ? Icons.history
                                                : Icons.play_circle_fill,
                                        color: badgeColor,
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(child: Text(trip.title)),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badgeColor.withValues(
                                                  alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.people,
                                                    size: 16,
                                                    color: badgeColor),
                                                const SizedBox(width: 2),
                                                Text(
                                                    '${trip.participants.length}',
                                                    style: TextStyle(
                                                        color: badgeColor)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badgeColor.withValues(
                                                  alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.receipt_long,
                                                    size: 16,
                                                    color: badgeColor),
                                                const SizedBox(width: 2),
                                                Text('${trip.expenses.length}',
                                                    style: TextStyle(
                                                        color: badgeColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.get('from_to', params: {
                                              'start':
                                                  '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                                              'end':
                                                  '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}'
                                            }),
                                          ),
                                          Text(
                                              '${loc.get('participants')}: ${trip.participants.join(", ")}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.euro,
                                                  size: 16, color: badgeColor),
                                              const SizedBox(width: 2),
                                              Text(
                                                  '${trip.currency} ${total.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      color: badgeColor,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TripDetailPage(trip: trip),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
