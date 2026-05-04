import 'package:io_caravella_egm/manager/details/widgets/export_options_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'dart:async';
// ...existing code...

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart'; // still used for share temp file
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Removed legacy localization bridge imports (migration in progress)
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
// Replaced bottom sheet overview with full page navigation
import '../widgets/delete_expense_dialog.dart';
import '../../expense/pages/expense_form_page.dart';
import '../widgets/group_header.dart';
import '../widgets/group_total.dart';
import '../widgets/group_actions.dart';
import '../widgets/filtered_expense_list.dart';
import '../export/ofx_exporter.dart';
import '../export/csv_exporter.dart';
import '../export/markdown_exporter.dart';
import '../../../services/notification_manager.dart';

import 'unified_overview_page.dart';
import 'group_settings_page.dart';
import 'expense_search_page.dart';

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
  late final ScrollController _scrollController;
  bool _fabVisible = true; // controllo visibilità totale
  Timer? _fabIdleTimer; // timer per ri-mostrare il FAB dopo inattività
  bool _collapsedTitleVisible = false; // mostra titolo in appbar dopo scroll
  String? _newlyAddedExpenseId; // ID della spesa appena aggiunta per animazione
  double _headerExpandedHeight =
      300.0; // aggiornato in build(), usato in _onScroll

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
    final trip = await ExpenseGroupStorageV2.getTripById(widget.trip.id);
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
    final refreshed = await ExpenseGroupStorageV2.getTripById(_trip!.id);
    if (!mounted || refreshed == null) return;
    setState(() => _trip = refreshed);
    _groupNotifier?.setCurrentGroup(refreshed);
  }

  void _openUnifiedOverviewPage() {
    if (_trip == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UnifiedOverviewPage(trip: _trip!)),
    );
  }

  void _openSearchPage() {
    if (_trip == null) return;
    ExpenseSearchPage.show(
      context,
      expenses: _trip!.expenses,
      categories: _trip!.categories,
      participants: _trip!.participants,
      currency: _trip!.currency,
      groupName: _trip!.title,
      onExpenseTap: _openEditExpense,
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
            dirPath = await FilePicker.getDirectoryPath(
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
            dirPath = await FilePicker.getDirectoryPath(
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
        onDownloadMarkdown: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final markdown = MarkdownExporter.generate(_trip, gloc);
          if (markdown.isEmpty) {
            if (rootContext.mounted) {
              AppToast.show(
                rootContext,
                gloc.no_expenses_to_export,
                type: ToastType.info,
              );
            }
            return;
          }
          final filename = MarkdownExporter.buildFilename(_trip);
          String? dirPath;
          try {
            dirPath = await FilePicker.getDirectoryPath(
              dialogTitle: gloc.markdown_select_directory_title,
            );
          } catch (_) {
            dirPath = null;
          }
          if (dirPath == null) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.markdown_save_cancelled,
              type: ToastType.info,
            );
            return;
          }
          try {
            final file = File('$dirPath/$filename');
            await file.writeAsString(markdown);
            if (!rootContext.mounted) return;
            final msg = gloc.markdown_saved_in(file.path);
            AppToast.show(rootContext, msg, type: ToastType.success);
            nav.pop();
          } catch (e) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.markdown_save_error,
              type: ToastType.error,
            );
          }
        },
        onShareMarkdown: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final markdown = MarkdownExporter.generate(_trip, gloc);
          if (markdown.isEmpty) {
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
            '${tempDir.path}/${MarkdownExporter.buildFilename(_trip)}',
          ).create();
          await file.writeAsString(markdown);
          if (!rootContext.mounted) return;
          await SharePlus.instance.share(
            ShareParams(
              text: '${_trip!.title} - Markdown',
              files: [XFile(file.path)],
            ),
          );
          if (!rootContext.mounted) return;
          nav.pop();
        },
      ),
    );
  }

  void _showSettingsPage() async {
    if (_trip == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GroupSettingsPage(
          trip: _trip!,
          onGroupUpdated: _refreshGroup,
          onGroupDeleted: () {
            if (mounted) {
              Navigator.of(context).pop(true); // Return to home
            }
          },
          onExportOptions: _showExportOptionsSheet,
        ),
      ),
    );

    // Refresh after returning from settings
    await _refreshGroup();
  }

  Future<void> _handlePinToggle() async {
    if (_trip == null) return;

    // Use the notifier to update pin state (handles storage + shortcuts)
    await Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    ).updateGroupPin(_trip!.id, !_trip!.pinned);

    await _refreshGroup();
  }

  void _showDeleteExpenseDialog(ExpenseDetails expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteExpenseDialog(
        expense: expense,
        onDelete: () async {
          // Capture context before async operations
          final gloc = gen.AppLocalizations.of(dialogContext);

          // Delete attachment files
          for (final attachmentPath in expense.attachments) {
            try {
              await File(attachmentPath).delete();
            } catch (e) {
              // File might not exist, ignore error
            }
          }

          // Rimuovi la spesa
          setState(() {
            _trip!.expenses.removeWhere((e) => e.id == expense.id);
          });

          // Salva le modifiche tramite storage helper
          await ExpenseGroupStorageV2.removeExpenseFromGroup(
            _trip!.id,
            expense.id,
          );

          // Update notification if enabled
          await NotificationManager().updateNotificationForGroupById(
            _trip!.id,
            gloc,
          );
        },
      ),
    );
  }

  void _showAddExpenseSheet() {
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ExpenseFormPage(
              group: _trip!,
              onExpenseSaved: (newExpense) async {
                final sheetCtx = context; // expense form page context
                final gloc = gen.AppLocalizations.of(sheetCtx);
                final newExpenseId = DateTime.now().millisecondsSinceEpoch
                    .toString();
                final expenseWithId = newExpense.copyWith(id: newExpenseId);

                // Persist using the new storage API
                await ExpenseGroupStorageV2.addExpenseToGroup(
                  widget.trip.id,
                  expenseWithId,
                );

                // Set the newly added expense ID for animation
                if (mounted) {
                  setState(() {
                    _newlyAddedExpenseId = newExpenseId;
                  });
                }

                // Refresh local state and notifier
                await _refreshGroup();
                _groupNotifier?.notifyGroupUpdated(widget.trip.id);

                // Update notification if enabled
                await NotificationManager().updateNotificationForGroupById(
                  widget.trip.id,
                  gloc,
                );

                // Check if we should prompt for rating
                // This is done after successful expense save
                RatingService.checkAndPromptForRating();

                // Clear the animation ID after a short delay to allow re-animation
                // for subsequent additions
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _newlyAddedExpenseId = null;
                    });
                  }
                });
                // Note: nav.pop() removed - ExpenseFormComponent handles navigation
                // when shouldAutoClose is true to avoid double pop back to home
              },
              onCategoryAdded: (categoryName) async {
                await _groupNotifier?.addCategory(categoryName);
                await _refreshGroup();
              },
              onParticipantAdded: (participantName) async {
                await _groupNotifier?.addParticipant(participantName);
                await _refreshGroup();
              },
            ),
          ),
        )
        .whenComplete(() {
          if (mounted) {
            _groupNotifier?.clearCurrentGroup();
          }
        });
  }

  Future<void> _openEditExpense(ExpenseDetails expense) async {
    if (_trip != null) {
      _groupNotifier?.setCurrentGroup(_trip!);
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (sheetCtx) => ExpenseFormPage(
              group: _trip!,
              initialExpense: expense,
              onExpenseSaved: (updatedExpense) async {
                final gloc = gen.AppLocalizations.of(sheetCtx);
                final expenseWithId = updatedExpense.copyWith(id: expense.id);

                // Persist the updated expense using the new storage API
                await ExpenseGroupStorageV2.updateExpenseToGroup(
                  _trip!.id,
                  expenseWithId,
                );

                // Refresh local state and notifier
                await _refreshGroup();
                _groupNotifier?.notifyGroupUpdated(_trip!.id);

                // Update notification if enabled
                await NotificationManager().updateNotificationForGroupById(
                  _trip!.id,
                  gloc,
                );

                if (!sheetCtx.mounted) return;
                AppToast.show(
                  sheetCtx,
                  gloc.expense_updated_success,
                  type: ToastType.success,
                );
                // Note: nav.pop() removed - ExpenseFormComponent handles navigation
                // when shouldAutoClose is true to avoid double pop back to home
              },
              onCategoryAdded: (categoryName) async {
                await _groupNotifier?.addCategory(categoryName);
                await _refreshGroup();
              },
              onParticipantAdded: (participantName) async {
                await _groupNotifier?.addParticipant(participantName);
                await _refreshGroup();
              },
              onDelete: () {
                Navigator.of(context).pop();
                _showDeleteExpenseDialog(expense);
              },
            ),
          ),
        )
        .whenComplete(() {
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

    // Mostra titolo nella appbar quando la flexible space è quasi collassata
    final threshold = (_headerExpandedHeight - 56).clamp(0.0, double.infinity);
    final shouldShow = _scrollController.offset > threshold;
    if (shouldShow != _collapsedTitleVisible && mounted) {
      setState(() => _collapsedTitleVisible = shouldShow);
    }
  }

  double _calculateBottomPadding() {
    final expenseCount = _trip?.expenses.length ?? 0;
    if (expenseCount > 5) {
      return 100.0;
    } else {
      // When there are few items, provide a larger bottom padding
      // to ensure the content fills the view vertically, pushing the list up.
      return 400.0;
    }
  }

  Widget _buildAnimatedFab(ColorScheme colorScheme) {
    if (_trip?.archived == true) return const SizedBox.shrink();

    // Hide FAB when there are no expenses (EmptyExpenseState handles the call-to-action)
    if (_trip?.expenses.isEmpty == true) return const SizedBox.shrink();
    if (_trip?.archived == true) return const SizedBox.shrink();

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
    final totalExpenses = trip.getTotalExpenses();
    final showCollapsedTitle = _collapsedTitleVisible;

    // Calcola altezza espansa: toolbar + avatar + titolo + totale + azioni
    const double toolbarH = 56.0;
    final circleSize = MediaQuery.of(context).size.width * 0.3;
    // GroupHeader: padding(16) + avatar(circleSize) + title(~34) + SizedBox(16)
    // + SizedBox(32) + Row(GroupTotal+GroupActions, ~60) + SizedBox(24)
    final headerContentH = 16 + circleSize + 34 + 16 + 32 + 60 + 24;
    final expandedH = toolbarH + headerContentH;
    _headerExpandedHeight = expandedH;

    final bg = GroupBackgroundUtils.resolve(
      trip,
      colorScheme,
      baseColor: colorScheme.surfaceContainer,
    );

    return AppSystemUI.surface(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: expandedH,
              toolbarHeight: toolbarH,
              collapsedHeight: toolbarH,
              elevation: 0,
              scrolledUnderElevation: 1,
              backgroundColor: colorScheme.surfaceContainer,
              foregroundColor: colorScheme.onSurface,
              centerTitle: false,
              title: AnimatedOpacity(
                opacity: showCollapsedTitle ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: Text(
                  trip.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: gen.AppLocalizations.of(context).options,
                  onPressed: () => _showSettingsPage(),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Sfondo: immagine quando presente, altrimenti surfaceContainer
                    if (bg.hasImage)
                      Image.file(
                        File(bg.imagePath!),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    else
                      ColoredBox(color: colorScheme.surfaceContainer),
                    // Overlay gradiente solo quando c'è un'immagine
                    if (bg.hasImage && bg.gradient != null)
                      DecoratedBox(
                        decoration: BoxDecoration(gradient: bg.gradient),
                      ),
                    // Contenuto header (sotto la toolbar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, toolbarH, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GroupHeader(
                            trip: trip,
                            onPinToggle: _handlePinToggle,
                          ),
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
                                    ? _openUnifiedOverviewPage
                                    : null,
                                onSearch: trip.expenses.isNotEmpty
                                    ? _openSearchPage
                                    : null,
                                onOptions: _showSettingsPage,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: colorScheme
                    .surfaceContainer, // background behind the decorated box
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilteredExpenseList(
                          expenses: trip.expenses,
                          currency: trip.currency,
                          onExpenseTap: _openEditExpense,
                          onAddExpense: _showAddExpenseSheet,
                          newlyAddedExpenseId: _newlyAddedExpenseId,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: _calculateBottomPadding(),
                  color: colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildAnimatedFab(colorScheme),
      ),
    );
  }
}
