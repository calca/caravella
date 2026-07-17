import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../group/pages/group_creation_wizard_page.dart';
import 'widgets/expense_group_empty_states.dart';
import 'widgets/swipeable_expense_group_card.dart';
import '../../home/search/group_search_page.dart';

class ExpesensHistoryPage extends StatefulWidget {
  const ExpesensHistoryPage({super.key});

  @override
  State<ExpesensHistoryPage> createState() => _ExpesensHistoryPageState();
}

class _ExpesensHistoryPageState extends State<ExpesensHistoryPage>
    with TickerProviderStateMixin {
  List<ExpenseGroup> _activeTrips = [];
  List<ExpenseGroup> _archivedTrips = [];
  List<ExpenseGroup> _filteredActiveTrips = [];
  List<ExpenseGroup> _filteredArchivedTrips = [];
  bool _loading = true;
  // Scroll + FAB state
  late final ScrollController _scrollController;
  bool _fabVisible = true;
  Timer? _fabIdleTimer;
  late final TabController _tabController;

  // (Removed) _statusOptions helper previously used for SegmentedButton.

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Tabs: Active | Archived (Material 3 expressive duration)
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 350),
    );
  }

  ExpenseGroupNotifier? _groupNotifier;

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onNotifierChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabIdleTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Wire notifier listener for external updates/deletes
    _groupNotifier?.removeListener(_onNotifierChanged);
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onNotifierChanged);
  }

  void _onNotifierChanged() async {
    final deleted = _groupNotifier?.deletedGroupIds ?? [];
    final updated = _groupNotifier?.updatedGroupIds ?? [];

    if ((deleted.isNotEmpty || updated.isNotEmpty) && mounted) {
      // Reload the trips to reflect external changes (deletions/updates)
      await _loadTrips();
      // Clear notifier queues after handling
      _groupNotifier?.clearDeletedGroups();
      _groupNotifier?.clearUpdatedGroups();
    }
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      // Load both active and archived trips simultaneously
      final activeTrips = await ExpenseGroupStorageV2.getActiveGroups();
      final archivedTrips = await ExpenseGroupStorageV2.getArchivedGroups();

      if (mounted) {
        setState(() {
          _activeTrips = activeTrips;
          _archivedTrips = archivedTrips;
          _filteredActiveTrips = _applyFilter(_activeTrips);
          _filteredArchivedTrips = _applyFilter(_archivedTrips);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(
          context,
          'Errore nel caricamento dei gruppi',
          type: ToastType.error,
        );
      }
    }
  }

  List<ExpenseGroup> _applyFilter(List<ExpenseGroup> trips) {
    // Sort: pinned groups first, then the rest
    final filtered = List<ExpenseGroup>.from(trips);
    filtered.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return 0;
    });
    return filtered;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_fabVisible && mounted) setState(() => _fabVisible = false);
      _fabIdleTimer?.cancel();
      _fabIdleTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted && !_fabVisible) setState(() => _fabVisible = true);
      });
    } else if (direction == ScrollDirection.forward) {
      if (!_fabVisible && mounted) setState(() => _fabVisible = true);
      _fabIdleTimer?.cancel();
    }
  }

  Widget _buildAnimatedFab(gen.AppLocalizations gloc) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      offset: _fabVisible ? Offset.zero : const Offset(0.3, 1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        opacity: _fabVisible ? 1 : 0,
        child: AddFab(
          heroTag: 'add-group-fab',
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GroupCreationWizardPage(),
              ),
            );
            if (result == true) await _loadTrips();
          },
          tooltip: gloc.add_trip,
        ),
      ),
    );
  }

  // Handler for archive toggle from the card: persist archive state and reload list.
  Future<void> _onArchiveToggle(String groupId, bool archived) async {
    // Persist archive state using the notifier (handles storage + shortcuts)
    await Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    ).updateGroupArchive(groupId, archived);
    // Small delay to allow storage to settle, then reload the list
    await Future.delayed(const Duration(milliseconds: 50));
    await _loadTrips();
  }

  Widget _buildTabContent(List<ExpenseGroup> trips, String tabType) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (trips.isEmpty) {
      return ExpenseGroupEmptyStates(
        searchQuery: '',
        periodFilter: tabType,
        onTripAdded: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GroupCreationWizardPage(),
            ),
          );
          if (result == true) {
            await _loadTrips();
          }
        },
      );
    }

    return ListView.builder(
      controller: null,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return SwipeableExpenseGroupCard(
          trip: trip,
          onArchiveToggle: _onArchiveToggle,
          onDelete: () => _loadTrips(),
          onPin: () => _loadTrips(),
        );
      },
    );
  }

  Widget _buildStatusSegmentedButton(BuildContext context) {
    // Replaced with a TabBar containing two tabs: Active | Archived
    final gloc = gen.AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: CaravellaTabBar(
        controller: _tabController,
        tabs: [
          Tab(text: gloc.status_active),
          Tab(text: gloc.status_archived),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return AppSystemUI.surface(
      child: Scaffold(
        appBar: const CaravellaAppBar(),
        floatingActionButton: _buildAnimatedFab(gloc),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SectionHeader(
                      title: gloc.expense_groups_title,
                      description: gloc.expense_groups_desc,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: gloc.show_search,
                    onPressed: () async {
                      await GroupSearchPage.show(context);
                      // Reload after returning from search (user may have
                      // changed pin/archive state from within the search page)
                      if (mounted) await _loadTrips();
                    },
                  ),
                ],
              ),
            ),
            // STATUS FILTER SEGMENTED BUTTONS
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: _buildStatusSegmentedButton(context),
            ),
            // MAIN CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  _buildTabContent(_filteredActiveTrips, 'active'),
                  _buildTabContent(_filteredArchivedTrips, 'archived'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
