import 'package:flutter/material.dart';

import '../../data/expense_details.dart';
import '../../data/expense_group.dart';
import '../expense/expense_form_component.dart';
import '../../data/expense_category.dart';
import '../../data/expense_group_storage.dart';
import '../group/add_new_expenses_group.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'tabs/overview_tab.dart';
import 'tabs/statistics_tab.dart';
import '../../widgets/currency_display.dart';
import '../../widgets/no_expense.dart';
import 'expense_amount_card.dart';

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
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header fisso
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.get('edit_expense'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showDeleteExpenseDialog(expense);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Contenuto scrollabile
            Flexible(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        MediaQuery.of(context).padding.bottom +
                        20,
                  ),
                  child: ExpenseFormComponent(
                    initialExpense: expense,
                    participants:
                        _trip!.participants.map((p) => p.name).toList(),
                    categories: _trip!.categories.map((c) => c.name).toList(),
                    tripStartDate: _trip!.startDate,
                    tripEndDate: _trip!.endDate,
                    shouldAutoClose: false,
                    onExpenseAdded: (updatedExpense) async {
                      // Aggiorna la spesa esistente
                      final expenseWithId = ExpenseDetails(
                        id: expense.id,
                        category: updatedExpense.category,
                        amount: updatedExpense.amount,
                        paidBy: updatedExpense.paidBy,
                        date: updatedExpense.date,
                        note: updatedExpense.note,
                      );

                      setState(() {
                        final index = _trip!.expenses
                            .indexWhere((e) => e.id == expense.id);
                        if (index != -1) {
                          _trip!.expenses[index] = expenseWithId;
                        }
                      });

                      // Salva le modifiche
                      final trips = await ExpenseGroupStorage.getAllGroups();
                      final tripIndex =
                          trips.indexWhere((t) => t.id == _trip!.id);
                      if (tripIndex != -1) {
                        trips[tripIndex] = _trip!;
                        await ExpenseGroupStorage.writeTrips(trips);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    onCategoryAdded: (categoryName) async {
                      // Gestisci l'aggiunta di una nuova categoria
                      final newCategory = ExpenseCategory(name: categoryName);
                      setState(() {
                        _trip!.categories.add(newCategory);
                      });

                      // Salva le modifiche
                      final trips = await ExpenseGroupStorage.getAllGroups();
                      final tripIndex =
                          trips.indexWhere((t) => t.id == _trip!.id);
                      if (tripIndex != -1) {
                        trips[tripIndex] = _trip!;
                        await ExpenseGroupStorage.writeTrips(trips);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOverviewSheet() {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
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
                      loc.get('overview'),
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
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
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
                      loc.get('statistics'),
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
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
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
                      loc.get('options'),
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
                          _trip!.pinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(_trip!.pinned
                            ? loc.get('unpin_group')
                            : loc.get('pin_group')),
                        onTap: () async {
                          Navigator.of(context).pop();
                          if (_trip!.pinned) {
                            await ExpenseGroupStorage.removePinnedTrip(
                                _trip!.id);
                          } else {
                            await ExpenseGroupStorage.setPinnedTrip(_trip!.id);
                          }
                          await _refreshTrip();
                        },
                      ),

                      // Archive/Unarchive action
                      ListTile(
                        leading: Icon(
                          _trip!.archived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(_trip!.archived
                            ? AppLocalizations(
                                    LocaleNotifier.of(context)?.locale ?? 'it')
                                .get('unarchive')
                            : AppLocalizations(
                                    LocaleNotifier.of(context)?.locale ?? 'it')
                                .get('archive')),
                        onTap: () async {
                          Navigator.of(context).pop();
                          final updatedTrip =
                              _trip!.copyWith(archived: !_trip!.archived);
                          final trips =
                              await ExpenseGroupStorage.getAllGroups();
                          final idx =
                              trips.indexWhere((v) => v.id == _trip!.id);
                          if (idx != -1) {
                            trips[idx] = updatedTrip;
                            await ExpenseGroupStorage.writeTrips(trips);
                          }
                          await _refreshTrip();
                        },
                      ),

                      const Divider(),

                      // Edit Group action
                      ListTile(
                        leading: Icon(
                          Icons.edit_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(loc.get('edit_group')),
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

                      const Divider(),

                      // Delete action
                      ListTile(
                        leading: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          loc.get('delete_group'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(loc.get('delete_group')),
                              content: Text(loc.get('delete_group_confirm')),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(loc.get('cancel')),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  child: Text(loc.get('delete')),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true && context.mounted) {
                            final trips =
                                await ExpenseGroupStorage.getAllGroups();
                            trips.removeWhere((v) => v.id == _trip!.id);
                            await ExpenseGroupStorage.writeTrips(trips);
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pop(true); // Torna alla lista e aggiorna
                            }
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

  void _showDeleteExpenseDialog(ExpenseDetails expense) {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('delete_expense')),
        content: Text(loc.get('delete_expense_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Rimuovi la spesa
              setState(() {
                _trip!.expenses.removeWhere((e) => e.id == expense.id);
              });

              // Salva le modifiche
              final trips = await ExpenseGroupStorage.getAllGroups();
              final tripIndex = trips.indexWhere((t) => t.id == _trip!.id);
              if (tripIndex != -1) {
                trips[tripIndex] = _trip!;
                await ExpenseGroupStorage.writeTrips(trips);
              }
            },
            child: Text(
              loc.get('delete'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseSheet() {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header fisso
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.get('add_expense'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Contenuto scrollabile
            Flexible(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        MediaQuery.of(context).padding.bottom +
                        20,
                  ),
                  child: ExpenseFormComponent(
                    participants:
                        _trip!.participants.map((p) => p.name).toList(),
                    categories: _trip!.categories.map((c) => c.name).toList(),
                    tripStartDate: _trip!.startDate,
                    tripEndDate: _trip!.endDate,
                    shouldAutoClose: false,
                    onExpenseAdded: (newExpense) async {
                      // Genera un ID univoco per la nuova spesa
                      final expenseWithId = ExpenseDetails(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: newExpense.category,
                        amount: newExpense.amount,
                        paidBy: newExpense.paidBy,
                        date: newExpense.date,
                        note: newExpense.note,
                      );

                      setState(() {
                        _trip!.expenses.add(expenseWithId);
                      });

                      // Salva le modifiche
                      final trips = await ExpenseGroupStorage.getAllGroups();
                      final tripIndex =
                          trips.indexWhere((t) => t.id == _trip!.id);
                      if (tripIndex != -1) {
                        trips[tripIndex] = _trip!;
                        await ExpenseGroupStorage.writeTrips(trips);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    onCategoryAdded: (categoryName) async {
                      // Gestisci l'aggiunta di una nuova categoria
                      final newCategory = ExpenseCategory(name: categoryName);
                      setState(() {
                        _trip!.categories.add(newCategory);
                      });

                      // Salva le modifiche
                      final trips = await ExpenseGroupStorage.getAllGroups();
                      final tripIndex =
                          trips.indexWhere((t) => t.id == _trip!.id);
                      if (tripIndex != -1) {
                        trips[tripIndex] = _trip!;
                        await ExpenseGroupStorage.writeTrips(trips);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
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
            expandedHeight: 160.0,
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
                        // Titolo del gruppo con icona stato a destra
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
                            const SizedBox(width: 12),
                            // Icona stato solo icona, neutra
                            Icon(
                              trip.archived
                                  ? Icons.archive_rounded
                                  : Icons.play_circle_fill_rounded,
                              size: 24,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Totale sotto il titolo - allineato a destra
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CurrencyDisplay(
                              value: totalExpenses,
                              currency: trip.currency,
                              valueFontSize: 42.0,
                              currencyFontSize: 28.0,
                              alignment: MainAxisAlignment.end,
                              showDecimals: true,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Expenses Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons - sempre visibili
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Overview IconButton
                      Tooltip(
                        message: _trip!.expenses.isNotEmpty
                            ? loc.get('show_overview')
                            : loc.get('no_expenses_to_display'),
                        child: IconButton.filled(
                          onPressed: _trip!.expenses.isNotEmpty
                              ? _showOverviewSheet
                              : null,
                          icon: const Icon(Icons.dashboard_customize_rounded),
                          iconSize: 24,
                          tooltip: loc.get('overview'),
                          style: IconButton.styleFrom(
                            backgroundColor: _trip!.expenses.isNotEmpty
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            foregroundColor: _trip!.expenses.isNotEmpty
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.outline,
                            minimumSize: const Size(56, 56),
                          ),
                        ),
                      ),
                      // Statistics IconButton
                      Tooltip(
                        message: _trip!.expenses.isNotEmpty
                            ? loc.get('show_statistics')
                            : loc.get('no_expenses_to_analyze'),
                        child: IconButton.filled(
                          onPressed: _trip!.expenses.isNotEmpty
                              ? _showStatisticsSheet
                              : null,
                          icon: const Icon(Icons.analytics_rounded),
                          iconSize: 24,
                          tooltip: loc.get('statistics'),
                          style: IconButton.styleFrom(
                            backgroundColor: _trip!.expenses.isNotEmpty
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            foregroundColor: _trip!.expenses.isNotEmpty
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.outline,
                            minimumSize: const Size(56, 56),
                          ),
                        ),
                      ),
                      // Menu Options IconButton (sempre abilitato)
                      Tooltip(
                        message: loc.get('options'),
                        child: IconButton.filled(
                          onPressed: _showOptionsSheet,
                          icon: const Icon(Icons.settings_rounded),
                          iconSize: 24,
                          tooltip: loc.get('options'),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.secondaryContainer,
                            foregroundColor: colorScheme.onSecondaryContainer,
                            minimumSize: const Size(56, 56),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Lista spese o messaggio vuoto
                  _trip!.expenses.isEmpty
                      ? NoExpense(
                          semanticLabel: loc.get('no_expense_label'),
                        )
                      : Column(
                          children: () {
                            final expenses = List.from(_trip!.expenses)
                              ..sort((a, b) => b.date.compareTo(a.date));
                            final expenseWidgets =
                                expenses.map<Widget>((expense) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: GestureDetector(
                                  onTap: () => _openEditExpense(expense),
                                  child: ExpenseAmountCard(
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
              onPressed: () => _showAddExpenseSheet(),
              label: Text(loc.get('add_expense_fab')),
              icon: const Icon(Icons.add_rounded),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
    );
  }
}
