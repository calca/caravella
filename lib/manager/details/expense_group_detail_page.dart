import 'package:flutter/material.dart';
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses =
        trip.expenses.fold<double>(0, (sum, s) => sum + (s.amount ?? 0));

    // Widget cerchio con immagine o lettere e icona di stato sovrapposta
    final double circleSize = MediaQuery.of(context).size.width * 0.3;
    Widget groupCircle = Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 2,
            ),
          ),
          child: trip.file != null && trip.file!.isNotEmpty
              ? ClipOval(
                  child: Image.asset(
                    trip.file!,
                    fit: BoxFit.cover,
                    width: circleSize,
                    height: circleSize,
                  ),
                )
              : Center(
                  child: Text(
                    trip.title.length >= 2
                        ? trip.title.substring(0, 2).toUpperCase()
                        : trip.title.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: circleSize * 0.4,
                        ),
                  ),
                ),
        ),
        if (trip.archived)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.archive_rounded,
                size: circleSize * 0.3,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar con gradiente
          SliverAppBar(
            expandedHeight: 10.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surfaceContainerHighest,
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
                  Center(child: groupCircle),
                  const SizedBox(height: 16),
                  Text(
                    trip.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Totale',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            CurrencyDisplay(
                              value: totalExpenses,
                              currency: trip.currency,
                              valueFontSize: 22.0,
                              currencyFontSize: 18.0,
                              alignment: MainAxisAlignment.start,
                              showDecimals: true,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: _trip!.expenses.isNotEmpty
                                  ? loc.get('show_overview')
                                  : loc.get('no_expenses_to_display'),
                              child: IconButton.filled(
                                onPressed: _trip!.expenses.isNotEmpty
                                    ? _showOverviewSheet
                                    : null,
                                icon: const Icon(
                                    Icons.dashboard_customize_rounded),
                                iconSize: 24,
                                tooltip: loc.get('overview'),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.surfaceContainerLowest,
                                  foregroundColor: colorScheme.onSurface
                                      .withValues(alpha: 0.85),
                                  minimumSize: const Size(54, 54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                  backgroundColor:
                                      colorScheme.surfaceContainerLowest,
                                  foregroundColor: colorScheme.onSurface
                                      .withValues(alpha: .85),
                                  minimumSize: const Size(54, 54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: loc.get('options'),
                              child: IconButton.filled(
                                onPressed: _showOptionsSheet,
                                icon: const Icon(Icons.settings_rounded),
                                iconSize: 24,
                                tooltip: loc.get('options'),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.surfaceContainerLowest,
                                  foregroundColor: colorScheme.onSurface
                                      .withValues(alpha: .85),
                                  minimumSize: const Size(54, 54),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                  // Titolo 'Attività' al posto della seconda row di bottoni
                  Text(
                    'Attività',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 20,
                        ),
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
