import '../group/add_new_expenses_group.dart';
import 'package:flutter/material.dart';
// ...existing code...

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart'; // still used for share temp file
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../data/expense_details.dart';
import '../../data/expense_group.dart';
import '../../state/expense_group_notifier.dart';
import '../../data/expense_group_storage.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import '../../widgets/app_toast.dart';
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
    // Header localizzato
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    buffer.writeln(
      [
        loc.get('csv_expense_name'),
        loc.get('csv_amount'),
        loc.get('csv_paid_by'),
        loc.get('csv_category'),
        loc.get('csv_date'),
        loc.get('csv_note'),
      ].join(','),
    );
    for (final e in _trip!.expenses) {
      buffer.writeln(
        [
          _escapeCsvValue(e.name ?? ''),
          e.amount?.toStringAsFixed(2) ?? '',
          _escapeCsvValue(e.paidBy.name),
          _escapeCsvValue(e.category.name),
          e.date.toIso8601String().split('T').first,
          _escapeCsvValue(e.note ?? ''),
        ].join(','),
      );
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

  /// Costruisce il nome file CSV includendo la data odierna in formato YYYY-MM-DD
  /// ed una versione "sanitizzata" del titolo del gruppo.
  String _buildCsvFilename() {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final rawTitle = _trip?.title ?? 'export';
    final safeTitle = rawTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return '${date}_${safeTitle}_export.csv';
  }

  ExpenseGroup? _trip;
  bool _deleted = false;
  ExpenseGroupNotifier? _groupNotifier;
  bool _reloading = false;
  double _listOpacity = 1.0;

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
    if (_reloading) return;
    setState(() {
      _reloading = true;
      _listOpacity = 0.3;
    });
    final trip = await ExpenseGroupStorage.getTripById(
      _trip?.id ?? widget.trip.id,
    );
    if (!mounted) return;
    if (trip != null) {
      setState(() {
        _trip = trip;
      });
      _groupNotifier?.setCurrentGroup(trip);
    }
    // Piccola pausa per percezione visiva
    await Future.delayed(const Duration(milliseconds: 180));
    if (mounted) {
      setState(() {
        _listOpacity = 1.0;
        _reloading = false;
      });
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
      builder: (sheetCtx) => OptionsSheet(
        trip: _trip!,
        onPinToggle: () async {
          if (_trip == null) return;
          final nav = Navigator.of(sheetCtx);
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
          if (!mounted) return;
          nav.pop();
        },
        onArchiveToggle: () async {
          if (_trip == null) return;
          final nav = Navigator.of(sheetCtx);
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
          if (!mounted) return;
          nav.pop();
        },
        onEdit: () async {
          if (_trip == null) return;
          final nav = Navigator.of(sheetCtx);
          nav.pop();
          await Future.delayed(const Duration(milliseconds: 200));
          if (!mounted) return;
          await nav.push(
            MaterialPageRoute(
              builder: (ctx) => AddNewExpensesGroupPage(trip: _trip!),
            ),
          );
          await _refreshTrip();
        },
        onDownloadCsv: () async {
          final preLoc = AppLocalizations(
            LocaleNotifier.of(context)?.locale ?? 'it',
          );
          final nav = Navigator.of(sheetCtx);
          final rootContext = context; // capture for toasts
          final csv = _generateCsvContent();
          if (csv.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                preLoc.get('no_expenses_to_export'),
                type: ToastType.info,
              );
            }
            return;
          }
          final filename = _buildCsvFilename();
          String? dirPath;
          try {
            dirPath = await FilePicker.platform.getDirectoryPath(
              dialogTitle: preLoc.get('csv_select_directory_title'),
            );
          } catch (_) {
            dirPath = null;
          }
          if (dirPath == null) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              preLoc.get('csv_save_cancelled'),
              type: ToastType.info,
            );
            return;
          }
          try {
            final file = File('$dirPath/$filename');
            await file.writeAsString(csv);
            if (!rootContext.mounted) return;
            final msg = preLoc.get('csv_saved_in', params: {'path': file.path});
            AppToast.show(rootContext, msg, type: ToastType.success);
            nav.pop();
          } catch (e) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              preLoc.get('csv_save_error'),
              type: ToastType.error,
            );
          }
        },
        onShareCsv: () async {
          final preLoc = AppLocalizations(
            LocaleNotifier.of(context)?.locale ?? 'it',
          );
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final csv = _generateCsvContent();
          if (csv.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                preLoc.get('no_expenses_to_export'),
                type: ToastType.info,
              );
            }
            return;
          }
          final tempDir = await getTemporaryDirectory();
          final file = await File(
            '${tempDir.path}/${_buildCsvFilename()}',
          ).create();
          await file.writeAsString(csv);
          if (!rootContext.mounted) return; // ensure still alive before share
          await SharePlus.instance.share(
            ShareParams(
              text: '${_trip!.title} - CSV',
              files: [XFile(file.path)],
            ),
          );
          if (!rootContext.mounted) return;
          nav.pop();
        },
        onDelete: () async {
          final preLoc = AppLocalizations(
            LocaleNotifier.of(context)?.locale ?? 'it',
          );
          final nav = Navigator.of(sheetCtx);
          final theme = Theme.of(context);
          final rootNav = Navigator.of(context);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: Text(preLoc.get('delete_group')),
              content: Text(preLoc.get('delete_group_confirm')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(preLoc.get('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: Text(
                    preLoc.get('delete'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true && _trip != null) {
            final trips = await ExpenseGroupStorage.getAllGroups();
            trips.removeWhere((t) => t.id == _trip!.id);
            await ExpenseGroupStorage.writeTrips(trips);
            if (!context.mounted) return;
            nav.pop(); // close sheet
            rootNav.pop(true); // go back to list
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
          final sheetCtx = context; // bottom sheet context
          final nav = Navigator.of(sheetCtx);
          final preLoc = AppLocalizations(
            LocaleNotifier.of(sheetCtx)?.locale ?? 'it',
          );
          final expenseWithId = newExpense.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          );
          await _groupNotifier?.addExpense(expenseWithId);
          await _refreshTrip();
          if (!sheetCtx.mounted) return;
          AppToast.show(
            sheetCtx,
            preLoc.get('expense_added_success'),
            type: ToastType.success,
          );
          nav.pop();
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
          final sheetCtx = context; // bottom sheet context
          final preLoc = AppLocalizations(
            LocaleNotifier.of(sheetCtx)?.locale ?? 'it',
          );
          final nav = Navigator.of(sheetCtx);
          final expenseWithId = updatedExpense.copyWith(id: expense.id);
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
          if (!sheetCtx.mounted) return;
          AppToast.show(
            sheetCtx,
            preLoc.get('expense_updated_success'),
            type: ToastType.success,
          );
          nav.pop();
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
      return const Scaffold(
        // backgroundColor centralizzato nel tema
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses = trip.expenses.fold<double>(
      0,
      (sum, s) => sum + (s.amount ?? 0),
    );

    return Scaffold(
      // backgroundColor centralizzato nel tema
      body: CustomScrollView(
        slivers: [
          // Hero AppBar con gradiente
          SliverAppBar(
            expandedHeight: 10.0,
            floating: false,
            pinned: true,
            // backgroundColor centralizzato nel tema
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                      const SizedBox(width: 8),
                      if (_reloading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          tooltip: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          onPressed: _refreshTrip,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Expenses Content
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _listOpacity,
                  curve: Curves.easeInOut,
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
                              semanticLabel: loc.get('no_expense_label'),
                            )
                          : ExpenseList(
                              expenses: trip.expenses,
                              currency: trip.currency,
                              onExpenseTap: _openEditExpense,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Spazio aggiuntivo per garantire lo scroll
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 100, // Altezza fissa per lo spazio
                color: colorScheme.surfaceContainer,
              ),
            ),
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
