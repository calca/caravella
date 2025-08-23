import '../group/pages/expenses_group_edit_page.dart';
import '../group/group_edit_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
// ...existing code...

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart'; // still used for share temp file
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../data/model/expense_details.dart';
import '../../data/model/expense_group.dart';
import '../../state/expense_group_notifier.dart';
import '../../data/expense_group_storage.dart';
import '../../widgets/material3_dialog.dart';
// Removed legacy localization bridge imports (migration in progress)
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../widgets/app_toast.dart';
import 'widgets/group_header.dart';
import 'widgets/group_actions.dart';
import 'widgets/group_total.dart';
import 'widgets/filtered_expense_list.dart';
import 'widgets/unified_overview_sheet.dart';
import 'widgets/options_sheet.dart';
import 'widgets/export_options_sheet.dart';
import 'widgets/expense_entry_sheet.dart';
import 'widgets/delete_expense_dialog.dart';
import '../../widgets/add_fab.dart';
import 'export/ofx_exporter.dart';
import 'export/csv_exporter.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  // Opacità lista spese (default 1.0, manual refresh stato rimosso)
  // final double _listOpacity = 1.0; // RIMOSSO: non più necessario

  // CSV export moved to CsvExporter

  // OFX export moved to OfxExporter.generate

  /// Costruisce il nome file OFX
  String _buildOfxFilename() {
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
    return '${date}_${safeTitle}_export.ofx';
  }

  ExpenseGroup? _trip;
  bool _deleted = false;
  ExpenseGroupNotifier? _groupNotifier;
  // Removed manual refresh state (_reloading, _listOpacity)
  bool _hideHeader = false; // animazione nascondi header quando filtri aperti
  late final ScrollController _scrollController;
  bool _fabVisible = true; // controllo visibilità totale
  Timer? _fabIdleTimer; // timer per ri-mostrare il FAB dopo inattività
  bool _collapsedTitleVisible = false; // mostra titolo in appbar dopo scroll

  @override
  void initState() {
    super.initState();
    _loadTrip();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabIdleTimer?.cancel();
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

  // _refreshTrip removed: state updates occur inline after each mutation.
  Future<void> _refreshGroup() async {
    if (_trip == null) return;
    final refreshed = await ExpenseGroupStorage.getTripById(_trip!.id);
    if (!mounted || refreshed == null) return;
    setState(() => _trip = refreshed);
    _groupNotifier?.setCurrentGroup(refreshed);
  }

  void _showUnifiedOverviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => UnifiedOverviewSheet(
          trip: _trip!,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showExportOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => ExportOptionsSheet(
        onDownloadCsv: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context; // capture for toasts
          final csv = CsvExporter.generate(_trip, gloc);
          if (csv.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                gloc.no_expenses_to_export,
                type: ToastType.info,
              );
            }
            return;
          }
          final filename = CsvExporter.buildFilename(_trip);
          String? dirPath;
          try {
            dirPath = await FilePicker.platform.getDirectoryPath(
              dialogTitle: gloc.csv_select_directory_title,
            );
          } catch (_) {
            dirPath = null;
          }
          if (dirPath == null) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.csv_save_cancelled,
              type: ToastType.info,
            );
            return;
          }
          try {
            final file = File('$dirPath/$filename');
            await file.writeAsString(csv);
            if (!rootContext.mounted) return;
            final msg = gloc.csv_saved_in(file.path);
            AppToast.show(rootContext, msg, type: ToastType.success);
            nav.pop();
          } catch (e) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.csv_save_error,
              type: ToastType.error,
            );
          }
        },
        onShareCsv: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final csv = CsvExporter.generate(_trip, gloc);
          if (csv.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                gloc.no_expenses_to_export,
                type: ToastType.info,
              );
            }
            return;
          }
          final tempDir = await getTemporaryDirectory();
          final file = await File(
            '${tempDir.path}/${CsvExporter.buildFilename(_trip)}',
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
        onDownloadOfx: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context; // capture for toasts
          final ofx = OfxExporter.generate(_trip);
          if (ofx.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                gloc.no_expenses_to_export,
                type: ToastType.info,
              );
            }
            return;
          }
          final filename = _buildOfxFilename();
          String? dirPath;
          try {
            dirPath = await FilePicker.platform.getDirectoryPath(
              dialogTitle: gloc.ofx_select_directory_title,
            );
          } catch (_) {
            dirPath = null;
          }
          if (dirPath == null) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.ofx_save_cancelled,
              type: ToastType.info,
            );
            return;
          }
          try {
            final file = File('$dirPath/$filename');
            await file.writeAsString(ofx);
            if (!rootContext.mounted) return;
            final msg = gloc.ofx_saved_in(file.path);
            AppToast.show(rootContext, msg, type: ToastType.success);
            nav.pop();
          } catch (e) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.ofx_save_error,
              type: ToastType.error,
            );
          }
        },
        onShareOfx: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final ofx = OfxExporter.generate(_trip);
          if (ofx.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                gloc.no_expenses_to_export,
                type: ToastType.info,
              );
            }
            return;
          }
          final tempDir = await getTemporaryDirectory();
          final file = await File(
            '${tempDir.path}/${_buildOfxFilename()}',
          ).create();
          await file.writeAsString(ofx);
          if (!rootContext.mounted) return; // ensure still alive before share
          await SharePlus.instance.share(
            ShareParams(
              text: '${_trip!.title} - OFX',
              files: [XFile(file.path)],
            ),
          );
          if (!rootContext.mounted) return;
          nav.pop();
        },
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => OptionsSheet(
        trip: _trip!,
        onPinToggle: () async {
          if (_trip == null) return;
          final nav = Navigator.of(sheetCtx);
          final updatedGroup = ExpenseGroup(
            expenses: [], // only metadata is needed
            title: _trip!.title,
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
          await _groupNotifier?.updateGroupMetadata(updatedGroup);
          await _refreshGroup();
          if (!mounted) return;
          nav.pop();
        },
        onArchiveToggle: () async {
          if (_trip == null) return;
          final nav = Navigator.of(sheetCtx);
          final updatedGroup = ExpenseGroup(
            expenses: [], // only metadata is needed
            title: _trip!.title,
            participants: _trip!.participants,
            startDate: _trip!.startDate,
            endDate: _trip!.endDate,
            currency: _trip!.currency,
            categories: _trip!.categories,
            timestamp: _trip!.timestamp,
            id: _trip!.id,
            file: _trip!.file,
            pinned: !_trip!.archived
                ? false
                : _trip!.pinned, // Remove pin when archiving
            archived: !_trip!.archived,
          );
          await _groupNotifier?.updateGroupMetadata(updatedGroup);
          await _refreshGroup();
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
              builder: (ctx) =>
                  ExpensesGroupEditPage(trip: _trip!, mode: GroupEditMode.edit),
            ),
          );
          await _refreshGroup();
        },
        onExportShare: () async {
          final nav = Navigator.of(sheetCtx);
          nav.pop();
          await Future.delayed(const Duration(milliseconds: 200));
          if (!mounted) return;
          _showExportOptionsSheet();
        },
        onDelete: () async {
          final nav = Navigator.of(sheetCtx);
          final rootNav = Navigator.of(context);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogCtx) => Material3Dialog(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: Text(gen.AppLocalizations.of(dialogCtx).delete_group),
              content: Text(
                gen.AppLocalizations.of(dialogCtx).delete_group_confirm,
              ),
              actions: [
                Material3DialogActions.cancel(
                  dialogCtx,
                  gen.AppLocalizations.of(dialogCtx).cancel,
                ),
                Material3DialogActions.destructive(
                  dialogCtx,
                  gen.AppLocalizations.of(dialogCtx).delete,
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
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
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ExpenseEntrySheet(
          group: _trip!,
          onExpenseSaved: (newExpense) async {
            final sheetCtx = context; // bottom sheet context
            final nav = Navigator.of(sheetCtx);
            final gloc = gen.AppLocalizations.of(sheetCtx);
            final expenseWithId = newExpense.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            );
            await _groupNotifier?.addExpense(expenseWithId);
            await _refreshGroup();
            if (!sheetCtx.mounted) return;
            AppToast.show(
              sheetCtx,
              gloc.expense_added_success,
              type: ToastType.success,
            );
            nav.pop();
          },
          onCategoryAdded: (categoryName) async {
            await _groupNotifier?.addCategory(categoryName);
            await _refreshGroup();
          },
          fullEdit: true,
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        _groupNotifier?.clearCurrentGroup();
      }
    });
  }

  Future<void> _openEditExpense(ExpenseDetails expense) async {
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: ExpenseEntrySheet(
          group: _trip!,
          initialExpense: expense,
          onExpenseSaved: (updatedExpense) async {
            final gloc = gen.AppLocalizations.of(sheetCtx);
            final nav = Navigator.of(sheetCtx);
            final expenseWithId = updatedExpense.copyWith(id: expense.id);
            final updatedExpenses = _trip!.expenses
                .map((e) {
                  return e.id == expense.id ? expenseWithId : e;
                })
                .toList(growable: false);
            final updatedGroup = ExpenseGroup(
              title: _trip!.title,
              expenses: List<ExpenseDetails>.from(updatedExpenses),
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
            await _refreshGroup();
            if (!sheetCtx.mounted) return;
            AppToast.show(
              sheetCtx,
              gloc.expense_updated_success,
              type: ToastType.success,
            );
            nav.pop();
          },
          onCategoryAdded: (categoryName) async {
            await _groupNotifier?.addCategory(categoryName);
            await _refreshGroup();
          },
          onDelete: () {
            Navigator.of(context).pop();
            _showDeleteExpenseDialog(expense);
          },
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        _groupNotifier?.clearCurrentGroup();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_fabVisible && mounted) setState(() => _fabVisible = false);
      // Avvia timer per ri-mostrare dopo inattività
      _fabIdleTimer?.cancel();
      _fabIdleTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted && !_fabVisible) {
          setState(() => _fabVisible = true);
        }
      });
    } else if (direction == ScrollDirection.forward) {
      if (!_fabVisible && mounted) setState(() => _fabVisible = true);
      // reset timer perché già visibile
      _fabIdleTimer?.cancel();
    }

    // Aggiorna visibilità titolo collassato in base allo scroll offset
    final shouldShow = _scrollController.offset > 40;
    if (shouldShow != _collapsedTitleVisible && mounted) {
      setState(() => _collapsedTitleVisible = shouldShow);
    }
  }

  Widget _buildAnimatedFab(ColorScheme colorScheme) {
    if (_trip?.archived == true) return const SizedBox.shrink();
    
    // Hide FAB when there are no expenses (EmptyExpenseState handles the call-to-action)
    if (_trip?.expenses.isEmpty == true) return const SizedBox.shrink();

    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      offset: _fabVisible ? Offset.zero : const Offset(0.3, 1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        opacity: _fabVisible ? 1 : 0,
        child: AddFab(
          heroTag: 'add-expense-fab',
          tooltip: gen.AppLocalizations.of(context).add_expense,
          onPressed: _showAddExpenseSheet,
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses = trip.expenses.fold<double>(
      0,
      (sum, s) => sum + (s.amount ?? 0),
    );
    final showCollapsedTitle = _hideHeader || _collapsedTitleVisible;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            scrolledUnderElevation: 1,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            toolbarHeight: 56,
            collapsedHeight: 56,
            centerTitle: false,
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: showCollapsedTitle
                  ? Text(
                      trip.title,
                      key: const ValueKey('appbar-title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : const SizedBox(key: ValueKey('appbar-empty')),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                ),
                child: _hideHeader
                    ? const SizedBox.shrink(key: ValueKey('header-hidden'))
                    : Padding(
                        key: const ValueKey('header-visible'),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GroupHeader(trip: trip),
                            const SizedBox(height: 32),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      ? _showUnifiedOverviewSheet
                                      : null,
                                  onOptions: _showOptionsSheet,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
              ),
            ),
          ),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilteredExpenseList(
                      expenses: trip.expenses,
                      currency: trip.currency,
                      onExpenseTap: _openEditExpense,
                      categories: trip.categories,
                      participants: trip.participants,
                      onFiltersVisibilityChanged: (visible) {
                        if (mounted) {
                          setState(() => _hideHeader = visible);
                        }
                      },
                      onAddExpense: _showAddExpenseSheet,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: trip.expenses.isEmpty ? 200 : 100, // More space when empty
                color: colorScheme.surfaceContainer,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAnimatedFab(colorScheme),
    );
  }
}
