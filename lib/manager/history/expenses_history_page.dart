import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import '../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import 'package:provider/provider.dart';
import '../../state/expense_group_notifier.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../group/pages/expenses_group_edit_page.dart';
import '../group/group_edit_mode.dart';
import '../../widgets/caravella_app_bar.dart';
import '../group/widgets/section_header.dart';
import 'widgets/expense_group_empty_states.dart';
import 'widgets/expense_group_card.dart';
import '../../widgets/app_toast.dart';

class ExpesensHistoryPage extends StatefulWidget {
  const ExpesensHistoryPage({super.key});

  @override
  State<ExpesensHistoryPage> createState() => _ExpesensHistoryPageState();
}

class _ExpesensHistoryPageState extends State<ExpesensHistoryPage>
    with TickerProviderStateMixin {
  List<ExpenseGroup> _allTrips = [];
  List<ExpenseGroup> _filteredTrips = [];
  String _statusFilter = 'active'; // active, archived
  String _searchQuery = '';
  bool _loading = true;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
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

    // Tabs: Active | Archived
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _statusFilter == 'archived' ? 1 : 0,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final newKey = _tabController.index == 1 ? 'archived' : 'active';
        if (newKey != _statusFilter) {
          _onStatusFilterChanged(newKey);
        }
      }
    });
  }

  ExpenseGroupNotifier? _groupNotifier;

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onNotifierChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
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
      List<ExpenseGroup> trips;

      // Carica i dati in base al filtro di stato
      switch (_statusFilter) {
        case 'archived':
          trips = await ExpenseGroupStorageV2.getArchivedGroups();
          break;
        case 'active':
        default:
          trips = await ExpenseGroupStorageV2.getActiveGroups();
          break;
      }

      if (mounted) {
        setState(() {
          _allTrips = trips;
          _filteredTrips = _applyFilter(_allTrips);
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
    // Applica solo il filtro di ricerca per titolo
    List<ExpenseGroup> filtered = trips;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (trip) =>
                trip.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    // Ordina: pinned prima, poi il resto
    filtered.sort((a, b) {
      if (a.pinned == b.pinned) return 0;
      return a.pinned ? -1 : 1;
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

  Widget _buildAnimatedFab(ColorScheme scheme, gen.AppLocalizations gloc) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      offset: _fabVisible ? Offset.zero : const Offset(0.3, 1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        opacity: _fabVisible ? 1 : 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'add-group-fab',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const ExpensesGroupEditPage(mode: GroupEditMode.create),
                ),
              );
              if (result == true) await _loadTrips();
            },
            tooltip: gloc.add_trip,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            elevation: 0,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ),
    );
  }

  void _onStatusFilterChanged(String key) {
    setState(() {
      _statusFilter = key;
      _loading = true; // Forza loading state
    });
    // Forza un piccolo delay prima di ricaricare
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadTrips(); // Ricarica i dati con il nuovo filtro
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
          _filteredTrips = _applyFilter(_allTrips);
        });
      }
    });
  }

  // Handler for archive toggle from the card: persist archive state and reload list.
  Future<void> _onArchiveToggle(String groupId, bool archived) async {
    // Persist archive state using the storage helper and then reload list.
    await ExpenseGroupStorageV2.updateGroupArchive(groupId, archived);
    // Small delay to allow storage to settle, then reload the list
    await Future.delayed(const Duration(milliseconds: 50));
    await _loadTrips();
  }

  Widget _buildSearchBar(BuildContext context, gen.AppLocalizations gloc) {
    final colorScheme = Theme.of(context).colorScheme;
    return SearchBar(
      controller: _searchController,
      hintText: gloc.search_groups,
      leading: const Icon(Icons.search_outlined),
      trailing: _searchQuery.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
            ]
          : [],
      onChanged: _onSearchChanged,
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatusSegmentedButton(BuildContext context) {
    // Replaced with a TabBar containing two tabs: Active | Archived
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        tabs: [
          Tab(text: gloc.status_active),
          Tab(text: gloc.status_archived),
        ],
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.outline,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const CaravellaAppBar(),
      floatingActionButton: _buildAnimatedFab(colorScheme, gloc),
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
                  icon: Icon(
                    _showSearchBar
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                  ),
                  tooltip: _showSearchBar ? gloc.hide_search : gloc.show_search,
                  onPressed: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                    });
                  },
                ),
              ],
            ),
          ),
          // HEADER SECTION - SEARCH BAR AT TOP
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              opacity: _showSearchBar ? 1 : 0,
              child: _showSearchBar
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: _buildSearchBar(context, gloc),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // STATUS FILTER SEGMENTED BUTTONS
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: _buildStatusSegmentedButton(context),
          ),
          // MAIN CONTENT
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _filteredTrips.isEmpty
                ? ExpsenseGroupEmptyStates(
                    searchQuery: _searchQuery,
                    periodFilter: _statusFilter,
                    onTripAdded: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExpensesGroupEditPage(
                            mode: GroupEditMode.create,
                          ),
                        ),
                      );
                      if (result == true) {
                        await _loadTrips();
                      }
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: _filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = _filteredTrips[index];
                      return ExpenseGroupCard(
                        trip: trip,
                        onArchiveToggle: _onArchiveToggle,
                        searchQuery: _searchQuery,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
