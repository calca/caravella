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
import 'tabs/statistics_tab.dart';
import '../../widgets/currency_display.dart';
import '../../widgets/widgets.dart';
import '../../widgets/no_expense.dart';
import 'trip_amount_card.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  ExpenseGroup? _trip;
  bool _deleted = false;

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

  Future<void> _openEditExpense(ExpenseDetails expense) async {
    final result = await Navigator.of(context).push<ExpenseActionResult>(
      MaterialPageRoute(
        builder: (context) => ExpenseEditPage(
          expense: expense,
          participants: _trip!.participants.map((p) => p.name).toList(),
          categories: _trip!.categories.map((c) => c.name).toList(),
          loc: AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it'),
          tripStartDate: _trip!.startDate,
          tripEndDate: _trip!.endDate,
        ),
      ),
    );
    if (result != null) {
      if (result.deleted) {
        setState(() {
          _trip!.expenses.removeWhere((e) => e.id == expense.id);
        });
      } else if (result.updatedExpense != null) {
        setState(() {
          final idx = _trip!.expenses.indexWhere((e) => e.id == expense.id);
          if (idx != -1) _trip!.expenses[idx] = result.updatedExpense!;
        });
      }
      // Salva le modifiche
      final trips = await ExpenseGroupStorage.getAllGroups();
      final tripIdx = trips.indexWhere((t) => t.id == _trip!.id);
      if (tripIdx != -1) {
        trips[tripIdx] = _trip!;
        await ExpenseGroupStorage.writeTrips(trips);
      }
    }
  }

  void _showOverviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.dashboard_customize_rounded),
                    const SizedBox(width: 8),
                    Text(
                      'Panoramica',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: OverviewTab(trip: _trip!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatisticsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded),
                    const SizedBox(width: 8),
                    Text(
                      'Statistiche',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: StatisticsTab(trip: _trip!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.6,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.settings_rounded),
                    const SizedBox(width: 8),
                    Text(
                      'Opzioni',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Pin/Unpin action
                      ListTile(
                        leading: Icon(
                          _trip!.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(_trip!.pinned ? 'Rimuovi pin' : 'Aggiungi pin'),
                        onTap: () async {
                          Navigator.of(context).pop();
                          if (_trip!.pinned) {
                            await ExpenseGroupStorage.removePinnedTrip(_trip!.id);
                          } else {
                            await ExpenseGroupStorage.setPinnedTrip(_trip!.id);
                          }
                          await _refreshTrip();
                        },
                      ),
                      
                      // Archive/Unarchive action
                      ListTile(
                        leading: Icon(
                          _trip!.archived ? Icons.unarchive_rounded : Icons.archive_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(_trip!.archived ? 
                          AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it').get('unarchive') : 
                          AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it').get('archive')),
                        onTap: () async {
                          Navigator.of(context).pop();
                          final updatedTrip = _trip!.copyWith(archived: !_trip!.archived);
                          final trips = await ExpenseGroupStorage.getAllGroups();
                          final idx = trips.indexWhere((v) => v.id == _trip!.id);
                          if (idx != -1) {
                            trips[idx] = updatedTrip;
                            await ExpenseGroupStorage.writeTrips(trips);
                          }
                          await _refreshTrip();
                        },
                      ),
                      
                      const Divider(),
                      
                      // Edit action
                      ListTile(
                        leading: Icon(
                          Icons.edit_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it').get('edit')),
                        onTap: () async {
                          Navigator.of(context).pop();
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddNewExpensesGroupPage(
                                  trip: _trip!,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }
    final trip = _trip;
    if (trip == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses =
        trip.expenses.fold<double>(0, (sum, s) => sum + (s.amount ?? 0));

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar con gradiente
          SliverAppBar(
            expandedHeight: 135.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surfaceContainerHighest,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titolo e totale
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                trip.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            CurrencyDisplay(
                              value: totalExpenses,
                              currency: trip.currency,
                              valueFontSize: 24.0,
                              currencyFontSize: 18.0,
                              alignment: MainAxisAlignment.end,
                              showDecimals: true,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Badge stato sotto il titolo
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: trip.archived
                                ? colorScheme.outline.withValues(alpha: 0.15)
                                : colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: trip.archived
                                  ? colorScheme.outline
                                  : colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trip.archived
                                    ? Icons.archive_rounded
                                    : Icons.play_circle_fill_rounded,
                                size: 14,
                                color: trip.archived
                                    ? colorScheme.outline
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip.archived
                                    ? loc.get('archived')
                                    : loc.get('active'),
                                style: TextStyle(
                                  color: trip.archived
                                      ? colorScheme.outline
                                      : colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Expenses Content in BaseCard
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            sliver: SliverToBoxAdapter(
              child: BaseCard(
                padding: EdgeInsets.zero,
                backgroundColor: colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action buttons se ci sono spese
                    if (_trip!.expenses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Overview IconButton
                            Tooltip(
                              message: 'Mostra panoramica',
                              child: IconButton.filled(
                                onPressed: _showOverviewSheet,
                                icon: const Icon(
                                    Icons.dashboard_customize_rounded),
                                iconSize: 24,
                                tooltip: 'Panoramica',
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.primaryContainer,
                                  foregroundColor:
                                      colorScheme.onPrimaryContainer,
                                  minimumSize: const Size(56, 56),
                                ),
                              ),
                            ),
                            // Statistics IconButton
                            Tooltip(
                              message: 'Mostra statistiche',
                              child: IconButton.filled(
                                onPressed: _showStatisticsSheet,
                                icon: const Icon(Icons.analytics_rounded),
                                iconSize: 24,
                                tooltip: 'Statistiche',
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.primaryContainer,
                                  foregroundColor:
                                      colorScheme.onPrimaryContainer,
                                  minimumSize: const Size(56, 56),
                                ),
                              ),
                            ),
                            // Menu Options IconButton
                            Tooltip(
                              message: 'Opzioni',
                              child: IconButton.filled(
                                onPressed: _showOptionsSheet,
                                icon: const Icon(Icons.settings_rounded),
                                iconSize: 24,
                                tooltip: 'Opzioni',
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.secondaryContainer,
                                  foregroundColor: colorScheme.onSecondaryContainer,
                                  minimumSize: const Size(56, 56),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Lista spese o messaggio vuoto
                    _trip!.expenses.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: NoExpense(
                              semanticLabel: loc.get('no_expense_label'),
                            ),
                          )
                        : Column(
                            children: () {
                              final expenses = List.from(_trip!.expenses)
                                ..sort((a, b) => b.date.compareTo(a.date));
                              final expenseWidgets =
                                  expenses.map<Widget>((expense) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: GestureDetector(
                                    onTap: () => _openEditExpense(expense),
                                    child: TripAmountCard(
                                      title: expense.category,
                                      coins: (expense.amount ?? 0).toInt(),
                                      checked: true,
                                      paidBy: expense.paidBy,
                                      category: null,
                                      date: expense.date,
                                      currency: _trip!.currency,
                                    ),
                                  ),
                                );
                              }).toList();

                              // Aggiungi spazio finale
                              expenseWidgets.add(const SizedBox(height: 12));
                              return expenseWidgets;
                            }(),
                          ),
                  ],
                ),
              ),
            ),
          ),

          // Spazio aggiuntivo per garantire lo scroll
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverToBoxAdapter(child: Container()),
          ),
        ],
      ),
      floatingActionButton: !trip.archived
          ? FloatingActionButton.extended(
              heroTag: 'add-expense-fab',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExpenseEditPage(
                      expense: ExpenseDetails(
                        category: '',
                        amount: 0,
                        paidBy: '',
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
              label: const Text('Aggiungi Spesa'),
              icon: const Icon(Icons.add_rounded),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
    );
  }
}
