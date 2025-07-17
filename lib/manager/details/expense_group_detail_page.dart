import 'package:flutter/material.dart';
// ...existing code...
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/expense_details.dart';
import '../../data/expense_group.dart';
import '../../state/expense_group_notifier.dart';
import '../expense/expense_form_component.dart';
import '../../data/expense_group_storage.dart';
import '../group/add_new_expenses_group.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'tabs/overview_tab.dart';
import 'tabs/statistics_tab.dart';
import 'widgets/group_header.dart';
import 'widgets/group_actions.dart';
import 'widgets/group_total.dart';
import 'widgets/expense_list.dart';
import 'widgets/empty_expenses.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  ExpenseGroup? _trip;
  bool _deleted = false;
  ExpenseGroupNotifier? _groupNotifier;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Rimuovi il listener precedente se esiste
    _groupNotifier?.removeListener(_onGroupChanged);

    // Ottieni il nuovo notifier e aggiungi il listener
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    // Rimuovi il listener in modo sicuro
    _groupNotifier?.removeListener(_onGroupChanged);
    _groupNotifier = null;
    super.dispose();
  }

  void _onGroupChanged() {
    final currentGroup = _groupNotifier?.currentGroup;

    // Se il gruppo corrente nel notifier è lo stesso che stiamo visualizzando, aggiorna
    if (currentGroup != null && _trip != null && currentGroup.id == _trip!.id) {
      if (mounted) {
        setState(() {
          _trip = currentGroup;
        });
      }
    }
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

      // Forza sempre l'aggiornamento del notifier con i nuovi dati
      _groupNotifier?.setCurrentGroup(trip);
    }
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
                child: Text(
                  loc.get('overview'),
                  style: Theme.of(context).textTheme.titleLarge,
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
                child: Text(
                  loc.get('statistics'),
                  style: Theme.of(context).textTheme.titleLarge,
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
                child: Text(
                  loc.get('options'),
                  style: Theme.of(context).textTheme.titleLarge,
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

                          // Imposta il gruppo corrente nel notifier prima di aprire l'editor
                          _groupNotifier?.setCurrentGroup(_trip!);

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
                            // Forza il refresh completo e aggiorna il notifier
                            await _refreshTrip();
                            // Pulisci e ricarica il notifier per essere sicuri
                            _groupNotifier?.clearCurrentGroup();
                          }
                        },
                      ),

                      const Divider(),

                      // Export CSV action
                      ListTile(
                        leading: Icon(
                          Icons.file_download_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(loc.get('export_csv')),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _exportToCsv();
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

    // Assicurati sempre che il notifier abbia i dati più aggiornati
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? _trip!;

          return Container(
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        participants: currentGroup.participants
                            .map((p) => p.name)
                            .toList(),
                        categories:
                            currentGroup.categories.map((c) => c.name).toList(),
                        tripStartDate: currentGroup.startDate,
                        tripEndDate: currentGroup.endDate,
                        shouldAutoClose: false,
                        showDateAndNote: true,
                        onExpenseAdded: (newExpense) async {
                          // Genera un ID univoco per la nuova spesa
                          final expenseWithId = ExpenseDetails(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            category: newExpense.category,
                            amount: newExpense.amount,
                            paidBy: newExpense.paidBy,
                            date: newExpense.date,
                            note: newExpense.note,
                          );

                          // Usa il notifier per aggiungere la spesa
                          await groupNotifier.addExpense(expenseWithId);

                          // Aggiorna lo stato locale
                          await _refreshTrip();

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        onCategoryAdded: (categoryName) async {
                          // Usa il notifier per aggiungere la categoria
                          await groupNotifier.addCategory(categoryName);

                          // Aggiorna lo stato locale
                          await _refreshTrip();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      // Pulisci il notifier quando il dialog si chiude
      if (mounted) {
        _groupNotifier?.clearCurrentGroup();
      }
    });
  }

  Future<void> _openEditExpense(ExpenseDetails expense) async {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    // Assicurati sempre che il notifier abbia i dati più aggiornati
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? _trip!;

          return Container(
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        participants: currentGroup.participants
                            .map((p) => p.name)
                            .toList(),
                        categories:
                            currentGroup.categories.map((c) => c.name).toList(),
                        tripStartDate: currentGroup.startDate,
                        tripEndDate: currentGroup.endDate,
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

                          // Aggiorna tramite il notifier
                          final updatedExpenses =
                              currentGroup.expenses.map((e) {
                            return e.id == expense.id ? expenseWithId : e;
                          }).toList();

                          final updatedGroup = ExpenseGroup(
                            title: currentGroup.title,
                            expenses: updatedExpenses,
                            participants: currentGroup.participants,
                            startDate: currentGroup.startDate,
                            endDate: currentGroup.endDate,
                            currency: currentGroup.currency,
                            categories: currentGroup.categories,
                            timestamp: currentGroup.timestamp,
                            id: currentGroup.id,
                            file: currentGroup.file,
                            pinned: currentGroup.pinned,
                          );

                          await groupNotifier.updateGroup(updatedGroup);

                          // Aggiorna lo stato locale
                          await _refreshTrip();

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        onCategoryAdded: (categoryName) async {
                          // Usa il notifier per aggiungere la categoria
                          await groupNotifier.addCategory(categoryName);

                          // Aggiorna lo stato locale
                          await _refreshTrip();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      // Pulisci il notifier quando il dialog si chiude
      if (mounted) {
        _groupNotifier?.clearCurrentGroup();
      }
    });
  }

  Future<void> _exportToCsv() async {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    if (_trip!.expenses.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.get('no_expenses_to_export'))),
        );
      }
      return;
    }

    try {
      // Genera il contenuto CSV
      final csvContent = _generateCsvContent();

      // Condividi il contenuto CSV come testo
      await SharePlus.instance.share(
        ShareParams(
          text:
              '${loc.get('export_csv_share_text')}${_trip!.title}\n\n$csvContent',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.get('export_csv_error'))),
        );
      }
    }
  }

  String _generateCsvContent() {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    // Header CSV
    final header = [
      loc.get('date'),
      loc.get('category'),
      loc.get('amount'),
      loc.get('currency'),
      loc.get('paid_by'),
      loc.get('note'),
    ].join(',');

    // Ordina le spese per data
    final sortedExpenses = List.from(_trip!.expenses)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Genera le righe CSV
    final rows = sortedExpenses.map((expense) {
      final date =
          '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}';
      final category = _escapeCsvValue(expense.category);
      final amount = expense.amount?.toStringAsFixed(2) ?? '0.00';
      final currency = _trip!.currency;
      final paidBy = _escapeCsvValue(expense.paidBy);
      final note = _escapeCsvValue(expense.note ?? '');

      return [date, category, amount, currency, paidBy, note].join(',');
    }).toList();

    return [header, ...rows].join('\n');
  }

  String _escapeCsvValue(String value) {
    // Esclude i valori CSV che contengono virgole, virgolette o newline
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }
    final trip = _trip;
    if (trip == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses =
        trip.expenses.fold<double>(0, (sum, s) => sum + (s.amount ?? 0));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar con gradiente
          SliverAppBar(
            expandedHeight: 10.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Header custom sotto l'AppBar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GroupHeader(trip: trip),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GroupTotal(
                          total: totalExpenses,
                          currency: trip.currency,
                        ),
                      ),
                      GroupActions(
                        hasExpenses: trip.expenses.isNotEmpty,
                        onOverview: trip.expenses.isNotEmpty
                            ? _showOverviewSheet
                            : null,
                        onStatistics: trip.expenses.isNotEmpty
                            ? _showStatisticsSheet
                            : null,
                        onOptions: _showOptionsSheet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
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
                  Text(
                    'Attività',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 20,
                        ),
                  ),
                  const SizedBox(height: 16),
                  trip.expenses.isEmpty
                      ? EmptyExpenses(
                          semanticLabel: loc.get('no_expense_label'))
                      : ExpenseList(
                          expenses: trip.expenses,
                          currency: trip.currency,
                          onExpenseTap: _openEditExpense,
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
