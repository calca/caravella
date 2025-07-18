import '../group/add_new_expenses_group.dart';
import 'package:flutter/material.dart';
// ...existing code...

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../data/expense_details.dart';
import '../../data/expense_group.dart';
import '../../state/expense_group_notifier.dart';
import '../../data/expense_group_storage.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'tabs/overview_tab.dart';
import 'widgets/group_header.dart';
import 'widgets/group_actions.dart';
import 'widgets/group_total.dart';
import 'widgets/expense_list.dart';
import 'widgets/empty_expenses.dart';
import 'widgets/statistics_sheet.dart';
import 'widgets/options_sheet.dart';
import 'widgets/expense_form_sheet.dart';
import 'widgets/edit_expense_sheet.dart';
import 'widgets/delete_expense_dialog.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  /// Genera il contenuto CSV delle spese del gruppo
  String _generateCsvContent() {
    if (_trip == null || _trip!.expenses.isEmpty) return '';
    final buffer = StringBuffer();
    // Header
    buffer.writeln('Categoria,Importo,Pagate da,Data,Nota');
    for (final e in _trip!.expenses) {
      buffer.writeln([
        _escapeCsvValue(e.category),
        e.amount?.toStringAsFixed(2) ?? '',
        _escapeCsvValue(e.paidBy),
        e.date.toIso8601String().split('T').first,
        _escapeCsvValue(e.note ?? ''),
      ].join(','));
    }
    return buffer.toString();
  }

  /// Escape per valori CSV
  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      value = value.replaceAll('"', '""');
      return '"$value"';
    }
    return value;
  }

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatisticsSheet(trip: _trip!),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OptionsSheet(
        trip: _trip!,
        onPinToggle: () async {
          if (_trip != null) {
            final updatedGroup = ExpenseGroup(
              title: _trip!.title,
              expenses: _trip!.expenses,
              participants: _trip!.participants,
              startDate: _trip!.startDate,
              endDate: _trip!.endDate,
              currency: _trip!.currency,
              categories: _trip!.categories,
              timestamp: _trip!.timestamp,
              id: _trip!.id,
              file: _trip!.file,
              pinned: !_trip!.pinned,
              archived: _trip!.archived,
            );
            await _groupNotifier?.updateGroup(updatedGroup);
            await _refreshTrip();
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        onArchiveToggle: () async {
          if (_trip != null) {
            final updatedGroup = ExpenseGroup(
              title: _trip!.title,
              expenses: _trip!.expenses,
              participants: _trip!.participants,
              startDate: _trip!.startDate,
              endDate: _trip!.endDate,
              currency: _trip!.currency,
              categories: _trip!.categories,
              timestamp: _trip!.timestamp,
              id: _trip!.id,
              file: _trip!.file,
              pinned: _trip!.pinned,
              archived: !_trip!.archived,
            );
            await _groupNotifier?.updateGroup(updatedGroup);
            await _refreshTrip();
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        onEdit: () async {
          if (_trip != null && context.mounted) {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 200));
            if (context.mounted) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AddNewExpensesGroupPage(trip: _trip!),
                ),
              );
              await _refreshTrip();
            }
          }
        },
        onExportCsv: () async {
          // Export CSV logic
          final csv = _generateCsvContent();
          final tempDir = await getTemporaryDirectory();
          final file =
              await File('${tempDir.path}/${_trip!.title}_export.csv').create();
          await file.writeAsString(csv);
          await Share.shareXFiles([XFile(file.path)],
              text: '${_trip!.title} - CSV');
          if (context.mounted) Navigator.of(context).pop();
        },
        onDelete: () async {
          final loc =
              AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(loc.get('delete_group')),
              content: Text(loc.get('delete_group_confirm')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc.get('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    loc.get('delete'),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true && _trip != null) {
            final trips = await ExpenseGroupStorage.getAllGroups();
            trips.removeWhere((t) => t.id == _trip!.id);
            await ExpenseGroupStorage.writeTrips(trips);
            if (context.mounted) {
              Navigator.of(context).pop(); // Close sheet
              Navigator.of(context).pop(true); // Go back
            }
          }
        },
      ),
    );
  }

  void _showDeleteExpenseDialog(ExpenseDetails expense) {
    showDialog(
      context: context,
      builder: (context) => DeleteExpenseDialog(
        expense: expense,
        onDelete: () async {
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
      ),
    );
  }

  void _showAddExpenseSheet() {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormSheet(
        group: _trip!,
        title: loc.get('add_expense'),
        onExpenseSaved: (newExpense) async {
          final expenseWithId = ExpenseDetails(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            category: newExpense.category,
            amount: newExpense.amount,
            paidBy: newExpense.paidBy,
            date: newExpense.date,
            note: newExpense.note,
          );
          await _groupNotifier?.addExpense(expenseWithId);
          await _refreshTrip();
          if (context.mounted) Navigator.of(context).pop();
        },
        onCategoryAdded: (categoryName) async {
          await _groupNotifier?.addCategory(categoryName);
          await _refreshTrip();
        },
        showDateAndNote: true,
      ),
    ).whenComplete(() {
      if (mounted) {
        _groupNotifier?.clearCurrentGroup();
      }
    });
  }

  Future<void> _openEditExpense(ExpenseDetails expense) async {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditExpenseSheet(
        group: _trip!,
        expense: expense,
        title: loc.get('edit_expense'),
        onExpenseAdded: (updatedExpense) async {
          final expenseWithId = ExpenseDetails(
            id: expense.id,
            category: updatedExpense.category,
            amount: updatedExpense.amount,
            paidBy: updatedExpense.paidBy,
            date: updatedExpense.date,
            note: updatedExpense.note,
          );
          final updatedExpenses = _trip!.expenses.map((e) {
            return e.id == expense.id ? expenseWithId : e;
          }).toList();
          final updatedGroup = ExpenseGroup(
            title: _trip!.title,
            expenses: updatedExpenses,
            participants: _trip!.participants,
            startDate: _trip!.startDate,
            endDate: _trip!.endDate,
            currency: _trip!.currency,
            categories: _trip!.categories,
            timestamp: _trip!.timestamp,
            id: _trip!.id,
            file: _trip!.file,
            pinned: _trip!.pinned,
          );
          await _groupNotifier?.updateGroup(updatedGroup);
          await _refreshTrip();
          if (context.mounted) Navigator.of(context).pop();
        },
        onCategoryAdded: (categoryName) async {
          await _groupNotifier?.addCategory(categoryName);
          await _refreshTrip();
        },
        onDelete: () {
          Navigator.of(context).pop();
          _showDeleteExpenseDialog(expense);
        },
      ),
    ).whenComplete(() {
      if (mounted) {
        _groupNotifier?.clearCurrentGroup();
      }
    });
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
