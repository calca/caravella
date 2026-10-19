import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';

import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/delete_expense_dialog.dart';
import '../../expense/pages/expense_form_page.dart';
import '../widgets/expense_export_actions.dart';
import '../widgets/grouped_expense_list.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/group_balances_view.dart';
import '../widgets/group_detail_header.dart';
import '../widgets/group_map_card.dart';
import '../widgets/group_statistics_view.dart';
import 'expense_locations_map_page.dart';
import '../../../services/notification_manager.dart';

import 'group_settings_page.dart';
import 'expense_search_page.dart';
import '../../group/pages/expense_group_sync_page.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage>
    with SingleTickerProviderStateMixin {
  /// Fades the new view in when switching Expenses / Balances / Statistics,
  /// in step with the selector's sliding fill.
  late final AnimationController _sectionFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );

  void _selectSection(int i) {
    if (i == _section) return;
    setState(() => _section = i);
    if (MediaQuery.disableAnimationsOf(context)) return;
    _sectionFade.forward(from: 0);
  }

  // Opacità lista spese (default 1.0, manual refresh stato rimosso)
  // final double _listOpacity = 1.0; // RIMOSSO: non più necessario

  // CSV export moved to CsvExporter

  // OFX export moved to OfxExporter.generate and OfxExporter.buildFilename

  ExpenseGroup? _trip;
  bool _deleted = false;
  ExpenseGroupNotifier? _groupNotifier;
  // Removed manual refresh state (_reloading, _listOpacity)
  late final ScrollController _scrollController;
  bool _fabVisible = true; // controllo visibilità totale
  Timer? _fabIdleTimer; // timer per ri-mostrare il FAB dopo inattività
  bool _collapsedTitleVisible = false; // mostra titolo in appbar dopo scroll
  String? _newlyAddedExpenseId; // ID della spesa appena aggiunta per animazione
  static const double _topBarHeight = 64.0;

  /// Selected view: 0 expenses, 1 balances, 2 statistics.
  int _section = 0;

  /// Scroll offset past which the collapsed title is shown.
  double _collapsedTitleThreshold(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(56.0);

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
    _seenRevision = _groupNotifier?.revision ?? 0;
    _groupNotifier?.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    // Rimuovi il listener in modo sicuro
    _groupNotifier?.removeListener(_onGroupChanged);
    _groupNotifier = null;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _sectionFade.dispose();
    _fabIdleTimer?.cancel();
    super.dispose();
  }

  /// Last [ExpenseGroupNotifier.revision] seen: a newer one (e.g. a sync
  /// that changed groups) reloads this group from storage.
  int _seenRevision = 0;

  void _onGroupChanged() {
    final revision = _groupNotifier?.revision ?? 0;
    if (revision != _seenRevision) {
      _seenRevision = revision;
      unawaited(_reloadFromStorage());
    }
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
  Future<void> _reloadFromStorage() async {
    if (_trip == null) return;
    final fresh = await ExpenseGroupStorageV2.getTripById(_trip!.id);
    if (mounted && fresh != null) setState(() => _trip = fresh);
  }

  Future<void> _refreshGroup() async {
    if (_trip == null) return;
    final refreshed = await ExpenseGroupStorageV2.getTripById(_trip!.id);
    if (!mounted || refreshed == null) return;
    setState(() => _trip = refreshed);
    _groupNotifier?.setCurrentGroup(refreshed);
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
          onExportOptions: () => showExpenseExportOptionsSheet(context, _trip),
        ),
      ),
    );

    // Refresh after returning from settings
    await _refreshGroup();
  }

  void _showSyncPage() async {
    if (_trip == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => ExpenseGroupSyncPage(trip: _trip!)),
    );

    // Refresh after returning from sync settings
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
    final shouldShow =
        _scrollController.offset > _collapsedTitleThreshold(context);
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
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final pageColor = s.surfaceContainer;
    final topInset = MediaQuery.paddingOf(context).top;

    // Over a group color the top bar and title use its contrasting color;
    // once the bar turns opaque (scrolled) it follows the theme again.
    final bandColor = GroupHeaderBand.colorOf(trip, s);
    final bandForeground = GroupHeaderBand.foregroundOf(trip, s);
    final barForeground = _collapsedTitleVisible ? s.onSurface : bandForeground;
    final bool? forceStatusBarLight =
        bandColor != null && !_collapsedTitleVisible
        ? !ExpenseGroupColorPalette.isLightColor(bandColor)
        : null;

    final sections = [gloc.expenses, gloc.balances, gloc.statistics];

    final Widget content = switch (_section) {
      _ when trip.expenses.isEmpty => SliverToBoxAdapter(
        child: SizedBox(
          height: 420,
          child: EmptyExpenseState(onAddFirstExpense: _showAddExpenseSheet),
        ),
      ),
      0 => WeekGroupedExpenseSliver(
        expenses: trip.expenses,
        currency: trip.currency,
        onExpenseTap: _openEditExpense,
        highlightedExpenseId: _newlyAddedExpenseId,
      ),
      1 => SliverToBoxAdapter(child: GroupBalancesView(group: trip)),
      _ => SliverToBoxAdapter(child: GroupStatisticsView(group: trip)),
    };

    Widget roundButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
      Color? color,
    }) => Material(
      color: _collapsedTitleVisible ? Colors.transparent : s.raisedSurface,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        color: color ?? s.onSurface,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );

    return AppSystemUI.edgeToEdge(
      forceStatusBarLight: forceStatusBarLight,
      child: Scaffold(
        backgroundColor: pageColor,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GroupHeaderBand(
                          group: trip,
                          pageColor: pageColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          topInset + _topBarHeight + 4,
                          20,
                          20,
                        ),
                        child: GroupDetailHeader(
                          group: trip,
                          foreground: bandForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: PillSegmentedControl(
                      labels: sections,
                      selectedIndex: _section,
                      onChanged: _selectSection,
                      expand: true,
                    ),
                  ),
                ),
                SliverFadeTransition(
                  opacity: CurvedAnimation(
                    parent: _sectionFade,
                    curve: Curves.easeOutCubic,
                  ),
                  sliver: content,
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: _calculateBottomPadding()),
                ),
              ],
            ),
            // Top bar over the band: round buttons at rest, an opaque bar
            // with the group name once the title has scrolled away.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _collapsedTitleVisible
                  ? pageColor
                  : pageColor.withValues(alpha: 0),
              padding: EdgeInsets.fromLTRB(12, topInset + 4, 12, 4),
              child: SizedBox(
                height: _topBarHeight - 8,
                child: Row(
                  children: [
                    roundButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: gloc.accessibility_back_button,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _collapsedTitleVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          trip.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: barForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (trip.expenses.isNotEmpty) ...[
                      roundButton(
                        icon: Icons.search_rounded,
                        tooltip: gloc.search_expenses,
                        onPressed: _openSearchPage,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _GroupMenuButton(
                      background: _collapsedTitleVisible
                          ? Colors.transparent
                          : s.raisedSurface,
                      items: [
                        if (!trip.archived)
                          _MenuItem(
                            trip.pinned
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            trip.pinned ? gloc.unpin : gloc.pin,
                            _handlePinToggle,
                          ),
                        if (groupPlacesCount(trip) > 0)
                          _MenuItem(
                            Icons.map_outlined,
                            gloc.quick_action_map,
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExpenseLocationsMapPage(group: trip),
                              ),
                            ),
                          ),
                        _MenuItem(
                          Icons.sync_rounded,
                          gloc.sync_title,
                          _showSyncPage,
                        ),
                        if (trip.expenses.isNotEmpty)
                          _MenuItem(
                            Icons.ios_share_rounded,
                            gloc.export_share,
                            () => showExpenseExportOptionsSheet(context, trip),
                          ),
                        _MenuItem(
                          Icons.settings_outlined,
                          gloc.settings,
                          _showSettingsPage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildAnimatedFab(s),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
}

/// The group page's "more" button: a round ⋯ opening a menu with the less
/// frequent actions, so the top bar keeps only back and search.
class _GroupMenuButton extends StatelessWidget {
  final Color background;
  final List<_MenuItem> items;

  const _GroupMenuButton({required this.background, required this.items});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    return MenuAnchor(
      alignmentOffset: const Offset(-140, 4),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(s.raisedSurface),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            leadingIcon: Icon(item.icon),
            onPressed: item.onTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Text(item.label),
            ),
          ),
      ],
      builder: (context, controller, _) => Material(
        color: background,
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(Icons.more_horiz_rounded),
          color: s.onSurface,
          tooltip: gloc.more_options,
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    );
  }
}
