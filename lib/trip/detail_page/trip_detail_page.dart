import 'package:flutter/material.dart';
import 'expense_edit_page.dart';
import '../../trips_storage.dart';
import '../add_trip_page.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'tabs/expenses_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/statistics_tab.dart';
import '../../widgets/caravella_app_bar.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  Trip? _trip;
  bool _deleted = false;
  int _selectedTab = 0;

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: CaravellaAppBar(
        backgroundColor: colorScheme.surfaceVariant,
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
      floatingActionButton: _selectedTab == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 16),
              child: FloatingActionButton.extended(
                heroTag: 'add-expense-fab',
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExpenseEditPage(
                        expense: Expense(
                          description: '',
                          amount: 0,
                          paidBy: trip.participants.isNotEmpty
                              ? trip.participants.first
                              : '',
                          date: DateTime.now(),
                          note: null,
                        ),
                        participants: trip.participants,
                        categories: trip.categories,
                        loc: loc,
                      ),
                    ),
                  );
                  if (result is ExpenseActionResult &&
                      result.updatedExpense != null) {
                    final trips = await TripsStorage.readTrips();
                    final idx = trips.indexWhere((v) =>
                        v.title == trip.title &&
                        v.startDate == trip.startDate &&
                        v.endDate == trip.endDate);
                    if (idx != -1) {
                      trips[idx].expenses.add(result.updatedExpense!);
                      await TripsStorage.writeTrips(trips);
                      await _refreshTrip();
                    }
                  }
                },
                label: const Text('+',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                icon: const SizedBox.shrink(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flat info trip header (no Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
            ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Sezione tab a tutta larghezza, senza padding laterale
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                              value: 0,
                              icon: const Icon(Icons.receipt_long_rounded),
                            ),
                            ButtonSegment(
                              value: 1,
                              icon: const Icon(Icons.dashboard_customize_rounded),
                            ),
                            ButtonSegment(
                              value: 2,
                              icon: const Icon(Icons.bar_chart_rounded),
                            ),
                          ],
                          selected: <int>{_selectedTab},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _selectedTab = newSelection.first;
                            });
                          },
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return colorScheme.primary.withOpacity(0.15);
                              }
                              return Colors.transparent;
                            }),
                            foregroundColor: MaterialStateProperty.all(
                              colorScheme.onSurface,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Il contenuto dei tab ora ha lo stesso background e bordi inferiori arrotondati
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.only(
                        top: 12, left: 0, right: 0, bottom: 0),
                    child: Builder(
                      builder: (context) {
                        if (_selectedTab == 0) {
                          return ExpensesTab(trip: trip, loc: loc);
                        } else if (_selectedTab == 1) {
                          return OverviewTab(trip: trip);
                        } else {
                          return StatisticsTab(trip: trip);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
