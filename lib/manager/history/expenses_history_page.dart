import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import '../../data/model/expense_group.dart';
import '../../../data/expense_group_storage.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../group/pages/expenses_group_edit_page.dart';
import '../group/group_edit_mode.dart';
import '../../widgets/caravella_app_bar.dart';
import 'widgets/expense_group_empty_states.dart';
import 'widgets/expandable_search_bar.dart';
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
  String _statusFilter = 'all'; // active, all, archived
  String _searchQuery = '';
  bool _loading = true;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  // Scroll + FAB state
  late final ScrollController _scrollController;
  bool _fabVisible = true;
  Timer? _fabIdleTimer;

  List<Map<String, dynamic>> _statusOptions(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return [
      {
        'key': 'all',
        'label': gloc.status_all,
        'icon': Icons.all_inclusive_outlined,
      },
      {
        'key': 'active',
        'label': gloc.status_active,
        'icon': Icons.play_circle_outline,
      },
      {
        'key': 'archived',
        'label': gloc.status_archived,
        'icon': Icons.archive_outlined,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabIdleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      List<ExpenseGroup> trips;

      // Carica i dati in base al filtro di stato
      switch (_statusFilter) {
        case 'all':
          trips = await ExpenseGroupStorage.getAllGroups();
          break;
        case 'archived':
          trips = await ExpenseGroupStorage.getArchivedGroups();
          break;
        case 'active':
        default:
          trips = await ExpenseGroupStorage.getActiveGroups();
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

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        _onSearchChanged('');
      }
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

  Future<void> _updateTrip(ExpenseGroup updatedTrip) async {
    final allTrips = await ExpenseGroupStorage.getAllGroups();
    final index = allTrips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      allTrips[index] = updatedTrip;
      await ExpenseGroupStorage.writeTrips(allTrips);
      // Forza un breve delay per assicurare la persistenza
      await Future.delayed(const Duration(milliseconds: 50));
      // Ricarica i dati con il filtro corrente
      await _loadTrips();
    }
  }

  Widget _buildStatusFilterButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size(54, 54),
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
          // HEADER SECTION CON FILTRI E RICERCA
          Column(
            children: [
              // FILTRI E SEARCH BAR SULLA STESSA RIGA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    // STATUS FILTER BUTTONS con animazione di fade
                    if (!_isSearchExpanded)
                      AnimatedOpacity(
                        opacity: _isSearchExpanded ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _isSearchExpanded ? 0 : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _statusOptions(context).map((option) {
                              final isSelected = _statusFilter == option['key'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildStatusFilterButton(
                                  context,
                                  option['label'],
                                  option['icon'],
                                  isSelected,
                                  () => _onStatusFilterChanged(option['key']),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    // SPACER per spingere la search a destra
                    const Spacer(),
                    // SEARCH BOX ESPANDIBILE ALLINEATO A DESTRA
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      width: _isSearchExpanded
                          ? MediaQuery.of(context).size.width - 32
                          : 54, // Collapsed width aligned to filter buttons
                      child: ExpandableSearchBar(
                        controller: _searchController,
                        isExpanded: _isSearchExpanded,
                        searchQuery: _searchQuery,
                        onToggle: _toggleSearch,
                        onSearchChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = _filteredTrips[index];
                      return ExpenseGroupCard(
                        trip: trip,
                        onTripUpdated: _updateTrip,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
