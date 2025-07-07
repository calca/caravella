import 'package:flutter/material.dart';
import '../../data/expense_details.dart';
import '../../data/expense_group.dart';
import '../../expense/expense_edit_page.dart';
import '../../data/expense_group_storage.dart';
import '../group/add_new_expenses_group.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'tabs/expenses_tab.dart';
import 'tabs/overview_tab.dart';
import '../../widgets/currency_display.dart';
import '../../widgets/widgets.dart';
import 'tabs/statistics_tab.dart';
import '../../widgets/caravella_app_bar.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  ExpenseGroup? _trip;
  bool _deleted = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    final trip = await ExpenseGroupStorage.getTripById(widget.trip.id);
    if (!mounted) return;
    setState(() {
      _trip = trip;
      _deleted = trip == null;
    });
    if (_deleted && mounted) {
      Navigator.of(context).pop(true); // Torna in home e aggiorna
    }
  }

  Future<void> _refreshTrip() async {
    final trip =
        await ExpenseGroupStorage.getTripById(_trip?.id ?? widget.trip.id);
    if (!mounted) return;
    if (trip != null) {
      setState(() {
        _trip = trip;
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
    final hasExpenses = trip.expenses.isNotEmpty;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: CaravellaAppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: Icon(
              trip.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            tooltip: trip.pinned ? 'Rimuovi pin' : 'Aggiungi pin',
            onPressed: () async {
              if (trip.pinned) {
                await ExpenseGroupStorage.removePinnedTrip(trip.id);
              } else {
                await ExpenseGroupStorage.setPinnedTrip(trip.id);
              }
              await _refreshTrip();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: loc.get('edit'),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddNewExpensesGroupPage(
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
                        expense: ExpenseDetails(
                          category: '',
                          amount: 0,
                          paidBy: '', // Nessun partecipante pre-selezionato
                          date: DateTime.now(),
                          note: null,
                        ),
                        participants:
                            trip.participants.map((p) => p.name).toList(),
                        categories: trip.categories.map((c) => c.name).toList(),
                        loc: loc,
                        tripStartDate: trip.startDate,
                        tripEndDate: trip.endDate,
                      ),
                    ),
                  );
                  if (result is ExpenseActionResult &&
                      result.updatedExpense != null) {
                    final trips = await ExpenseGroupStorage.getAllGroups();
                    final idx = trips.indexWhere((v) => v.id == trip.id);
                    if (idx != -1) {
                      trips[idx].expenses.add(result.updatedExpense!);
                      await ExpenseGroupStorage.writeTrips(trips);
                    }
                  }
                  if (mounted) await _refreshTrip();
                },
                label: const Text('+',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                icon: const SizedBox.shrink(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flat info trip header
          BaseCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            backgroundColor: colorScheme.surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(0), // Per farlo aderire ai bordi
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
                              ?.copyWith()),
                      const SizedBox(height: 8),
                      Text(
                        trip.startDate != null && trip.endDate != null
                            ? '${trip.startDate!.day}/${trip.startDate!.month}/${trip.startDate!.year} - ${trip.endDate!.day}/${trip.endDate!.month}/${trip.endDate!.year}'
                            : 'Date non definite',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(trip.participants.join(", "),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CurrencyDisplay(
                      value: trip.expenses
                          .fold<double>(0, (sum, s) => sum + (s.amount ?? 0)),
                      currency: trip.currency,
                      valueFontSize: 20.0,
                      currencyFontSize: 14.0,
                      alignment: MainAxisAlignment.end,
                      showDecimals: true,
                      color: Theme.of(context).colorScheme.primary,
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
                              enabled: true,
                            ),
                            ButtonSegment(
                              value: 1,
                              icon:
                                  const Icon(Icons.dashboard_customize_rounded),
                              enabled: hasExpenses,
                            ),
                            ButtonSegment(
                              value: 2,
                              icon: const Icon(Icons.bar_chart_rounded),
                              enabled: hasExpenses,
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
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>(
                                    (states) {
                              if (states.contains(WidgetState.selected)) {
                                return colorScheme.primary
                                    .withAlpha((0.15 * 255).toInt());
                              }
                              return Colors.transparent;
                            }),
                            foregroundColor: WidgetStateProperty.all(
                              colorScheme.onSurface,
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                            ),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8)),
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
