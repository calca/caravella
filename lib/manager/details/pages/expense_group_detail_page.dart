import 'section_swipe.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';

import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../home/cards/widgets/add_expense_controller.dart';
import '../widgets/delete_expense_dialog.dart';
import '../../expense/pages/expense_form_page.dart';
import '../widgets/expense_export_actions.dart';
import '../widgets/grouped_expense_list.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/group_balances_view.dart';
import '../widgets/group_detail_header.dart';
import '../widgets/group_detail_top_bar.dart';
import '../widgets/group_statistics_view.dart';
import '../widgets/group_welcome_card.dart';
import '../../../services/notification_manager.dart';

import 'group_settings_page.dart';
import '../../group/group_edit_mode.dart';
import '../../group/pages/expense_group_other_page.dart';
import 'expense_search_page.dart';
import '../../group/pages/expense_group_sync_page.dart';
import '../../budget/budget_detail_sheet.dart';
import '../../budget/budget_settings_sheet.dart';

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

  ExpenseGroup? _trip;
  bool _deleted = false;
  ExpenseGroupNotifier? _groupNotifier;
  late final ScrollController _scrollController;
  bool _fabVisible = true; // controllo visibilità totale
  Timer? _fabIdleTimer; // shows the FAB again after a pause
  bool _collapsedTitleVisible = false; // group name in the top bar

  /// The top bar turns opaque as soon as content scrolls under it.
  bool _barOpaque = false;
  String? _newlyAddedExpenseId; // just added, to highlight

  /// Selected view: 0 expenses, 1 balances, 2 statistics.
  int _section = 0;

  /// Horizontal travel of the current swipe over the content.
  double _swipeDistance = 0;

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

    _groupNotifier?.removeListener(_onGroupChanged);

    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _seenRevision = _groupNotifier?.revision ?? 0;
    _groupNotifier?.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
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

  /// Name of the device that shared this group, while its one-time welcome
  /// is pending ('' when unknown); null once dismissed or for own groups.
  String? get _welcomeFrom => PreferencesService.isInitialized
      ? PreferencesService.instance.sharedGroups.pendingWelcomeFrom(
          widget.trip.id,
        )
      : null;

  Future<void> _dismissWelcome() async {
    await PreferencesService.instance.sharedGroups.clearPendingWelcome(
      widget.trip.id,
    );
    if (mounted) setState(() {});
  }

  void _onGroupChanged() {
    final revision = _groupNotifier?.revision ?? 0;
    if (revision != _seenRevision) {
      _seenRevision = revision;
      unawaited(_reloadFromStorage());
    }
    final currentGroup = _groupNotifier?.currentGroup;

    // The notifier's current group is this one, changed: show it.
    // Opening the expense form sets this very group as current: nothing
    // changed, and rebuilding the page under the incoming one made it stutter.
    if (currentGroup != null &&
        _trip != null &&
        currentGroup.id == _trip!.id &&
        !identical(currentGroup, _trip)) {
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
      Navigator.of(context).pop(true); // back to Home, which refreshes
    }
  }

  Future<void> _reloadFromStorage() async {
    if (_trip == null) return;
    final fresh = await ExpenseGroupStorageV2.getTripById(_trip!.id);
    if (mounted && fresh != null) setState(() => _trip = fresh);
  }

  /// Settle up ticked a payment as paid or back: shown at once, then saved
  /// (and synced with the group).
  Future<void> _savePayments(List<SettlePayment> payments) async {
    final trip = _trip;
    if (trip == null) return;
    setState(() => _trip = trip.copyWith(payments: payments));
    final saved = await ExpenseGroupStorageV2.updateGroupPayments(
      trip.id,
      payments,
    );
    if (!saved) {
      LoggerService.warning('Payments not saved', name: 'ui.balances');
    }
    await _refreshGroup();
    _groupNotifier?.notifyGroupUpdated(trip.id);
  }

  /// "Today" tapped with a budget: its sheet, and from there the budget's
  /// settings.
  Future<void> _showBudget() async {
    final trip = _trip;
    if (trip == null) return;
    await showBudgetDetailSheet(
      context,
      group: trip,
      onChangeBudget: _changeBudget,
    );
  }

  Future<void> _changeBudget() async {
    final trip = _trip;
    if (trip == null || !mounted) return;
    final result = await showBudgetSettingsSheet(
      context,
      budget: trip.budget,
      currency: trip.currency,
      groupType: trip.groupType,
    );
    final budget = switch (result) {
      BudgetSaved(:final budget) => budget,
      BudgetRemoved() => null,
      null => trip.budget,
    };
    if (result == null || budget == trip.budget) return;
    setState(() => _trip = trip.copyWith(budget: budget));
    final saved = await ExpenseGroupStorageV2.updateGroupBudget(
      trip.id,
      budget,
    );
    if (!saved) LoggerService.warning('Budget not saved', name: 'ui.budget');
    await _refreshGroup();
    _groupNotifier?.notifyGroupUpdated(trip.id);
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

  /// The group's "Other" settings, where automatic location is turned on.
  Future<void> _openLocationSetting() async {
    if (_trip == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ExpenseGroupOtherPage(trip: _trip!, mode: GroupEditMode.edit),
      ),
    );
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

          setState(() {
            _trip!.expenses.removeWhere((e) => e.id == expense.id);
          });

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

  /// Same quick-add sheet as Home; the controller persists the expense,
  /// refreshes the notifier, updates the notification and prompts for rating.
  /// The page only adds the highlight animation and its own refresh.
  void _showAddExpenseSheet() {
    final trip = _trip;
    if (trip == null) return;
    AddExpenseController(
      group: trip,
      onExpensePersisted: (expense) {
        if (mounted) setState(() => _newlyAddedExpenseId = expense.id);
      },
      onExpenseAdded: () async {
        await _refreshGroup();
        // Clear the id after a short delay so later additions animate again.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _newlyAddedExpenseId = null);
        });
      },
    ).showAddExpenseSheet(context, trip);
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
      // Show it again after a pause
      _fabIdleTimer?.cancel();
      _fabIdleTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted && !_fabVisible) {
          setState(() => _fabVisible = true);
        }
      });
    } else if (direction == ScrollDirection.forward) {
      if (!_fabVisible && mounted) setState(() => _fabVisible = true);
      _fabIdleTimer?.cancel();
    }

    // The group name shows in the top bar once the title has scrolled away
    final shouldShow =
        _scrollController.offset > _collapsedTitleThreshold(context);
    final opaque = _scrollController.offset > 2;
    if ((shouldShow != _collapsedTitleVisible || opaque != _barOpaque) &&
        mounted) {
      setState(() {
        _collapsedTitleVisible = shouldShow;
        _barOpaque = opaque;
      });
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

  Widget _buildAnimatedFab() {
    // Archived groups take no expenses; with none yet, EmptyExpenseState
    // has the call to action.
    if (_trip?.archived == true || _trip?.expenses.isEmpty == true) {
      return const SizedBox.shrink();
    }

    // Only on Expenses, where the new expense shows up: on Balances it
    // would sit over the payments' paid buttons, on Statistics over the
    // charts.
    final shown = _fabVisible && _section == 0;
    return IgnorePointer(
      ignoring: !shown,
      child: ExcludeSemantics(
        excluding: !shown,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          offset: shown ? Offset.zero : const Offset(0.3, 1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            opacity: shown ? 1 : 0,
            child: AddFab(
              heroTag: 'add-expense-fab',
              tooltip: gen.AppLocalizations.of(context).add_expense,
              onPressed: _showAddExpenseSheet,
            ),
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
    final hasPhoto = GroupHeaderBand.photoOf(trip) != null;
    final bool? forceStatusBarLight = _barOpaque || hasPhoto
        ? null
        : bandColor != null
        ? !ExpenseGroupColorPalette.isLightColor(bandColor)
        : null;

    final sections = [gloc.expenses, gloc.balances, gloc.statistics];
    // A group with no expenses has nothing but its empty state to show.
    if (trip.expenses.isEmpty) _section = 0;

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
      1 => SliverToBoxAdapter(
        child: GroupBalancesView(group: trip, onPaymentsChanged: _savePayments),
      ),
      _ => SliverToBoxAdapter(
        child: GroupStatisticsView(
          group: trip,
          onEnableLocation: _openLocationSetting,
        ),
      ),
    };

    return AppSystemUI.edgeToEdge(
      forceStatusBarLight: forceStatusBarLight,
      child: Scaffold(
        backgroundColor: pageColor,
        body: Stack(
          children: [
            // Swipe left / right over the page to move between Expenses,
            // Balances and Statistics, like tabs.
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (_) => _swipeDistance = 0,
              onHorizontalDragUpdate: (d) => _swipeDistance += d.delta.dx,
              onHorizontalDragEnd: (d) {
                if (trip.expenses.isEmpty) return;
                final next = sectionAfterSwipe(
                  current: _section,
                  count: sections.length,
                  distance: _swipeDistance,
                  velocity: d.primaryVelocity ?? 0,
                  rtl: Directionality.of(context) == TextDirection.rtl,
                );
                if (next != null) _selectSection(next);
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: GroupHeaderBand(
                      group: trip,
                      topInset: topInset,
                      header: (foreground) => GroupDetailHeader(
                        group: trip,
                        foreground: foreground,
                        onOpenSync: _showSyncPage,
                        onOpenBudget: _showBudget,
                      ),
                    ),
                  ),
                  if (_welcomeFrom case final from?)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      sliver: SliverToBoxAdapter(
                        child: GroupWelcomeCard(
                          group: trip,
                          from: from,
                          onDismiss: _dismissWelcome,
                          onAddExpense: () {
                            _dismissWelcome();
                            _showAddExpenseSheet();
                          },
                        ),
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
                        disabled: trip.expenses.isEmpty
                            ? const {1, 2}
                            : const {},
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
            ),
            // Top bar over the band: round buttons at rest, an opaque bar
            // with the group name once the title has scrolled away.
            GroupDetailTopBar(
              title: trip.title,
              opaque: _barOpaque,
              titleVisible: _collapsedTitleVisible,
              bandForeground: bandForeground,
              pageColor: pageColor,
              onSearch: trip.expenses.isNotEmpty ? _openSearchPage : null,
              menuItems: [
                if (!trip.archived)
                  GroupMenuItem(
                    trip.pinned
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    trip.pinned ? gloc.unpin : gloc.pin,
                    _handlePinToggle,
                  ),
                // The map opens from its card in Statistics.
                GroupMenuItem(
                  Icons.sync_rounded,
                  gloc.sync_title,
                  _showSyncPage,
                ),
                // Share & export lives in the group's settings
                // (rarely used, kept out of this menu).
                GroupMenuItem(
                  Icons.settings_outlined,
                  gloc.settings,
                  _showSettingsPage,
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: _buildAnimatedFab(),
      ),
    );
  }
}
