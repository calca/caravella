import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/expense_group.dart';
import '../../../data/expense_group_storage.dart';
import '../../app_localizations.dart';
import '../group/add_new_expenses_group.dart';
import '../../state/locale_notifier.dart';
import '../../widgets/caravella_app_bar.dart';
import 'widgets/trip_empty_states.dart';
import 'widgets/expandable_search_bar.dart';
import 'widgets/trip_card.dart';
import 'widgets/trip_options_sheet.dart';

class ExpesensHistoryPage extends StatefulWidget {
  const ExpesensHistoryPage({super.key});

  @override
  State<ExpesensHistoryPage> createState() => _ExpesensHistoryPageState();
}

class _ExpesensHistoryPageState extends State<ExpesensHistoryPage>
    with TickerProviderStateMixin {
  List<ExpenseGroup> _allTrips = [];
  List<ExpenseGroup> _filteredTrips = [];
  String _periodFilter = 'all';
  String _searchQuery = '';
  bool _loading = true;
  bool _showFilters = false;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  late AnimationController _filterAnimationController;

  final List<Map<String, dynamic>> _periodOptions = [
    {'key': 'all', 'label': 'Tutti', 'icon': Icons.all_inclusive},
    {'key': 'last12', 'label': 'Ultimi 12 mesi', 'icon': Icons.calendar_today},
    {'key': 'future', 'label': 'Futuri', 'icon': Icons.schedule},
    {'key': 'past', 'label': 'Passati', 'icon': Icons.history},
  ];

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadTrips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final trips = await ExpenseGroupStorage.getAllGroups();
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
        _showErrorSnackBar('Errore nel caricamento dei gruppi');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Riprova',
          onPressed: _loadTrips,
        ),
      ),
    );
  }

  List<ExpenseGroup> _applyFilter(List<ExpenseGroup> trips) {
    final now = DateTime.now();

    // Prima applica il filtro per periodo
    List<ExpenseGroup> filteredByPeriod;
    switch (_periodFilter) {
      case 'last12':
        filteredByPeriod = trips
            .where((t) =>
                t.startDate?.isAfter(now.subtract(Duration(days: 365))) ??
                false)
            .toList();
        break;
      case 'future':
        filteredByPeriod =
            trips.where((t) => t.startDate?.isAfter(now) ?? false).toList();
        break;
      case 'past':
        filteredByPeriod =
            trips.where((t) => t.endDate?.isBefore(now) ?? false).toList();
        break;
      default:
        filteredByPeriod = trips;
    }

    // Poi applica il filtro di ricerca per titolo
    if (_searchQuery.isEmpty) {
      return filteredByPeriod;
    }

    return filteredByPeriod
        .where((trip) =>
            trip.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onFilterChanged(String key) {
    setState(() {
      _periodFilter = key;
      _filteredTrips = _applyFilter(_allTrips);
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

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
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

  Future<void> _deleteTrip(ExpenseGroup trip) async {
    final allTrips = await ExpenseGroupStorage.getAllGroups();
    allTrips.removeWhere((t) => t.id == trip.id);
    await ExpenseGroupStorage.writeTrips(allTrips);
    setState(() {
      _allTrips = allTrips;
      _filteredTrips = _applyFilter(_allTrips);
    });
  }

  void _showTripOptions(ExpenseGroup trip) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TripOptionsSheet(
        trip: trip,
        onTripDeleted: () => _deleteTrip(trip),
        onTripUpdated: _loadTrips,
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    return Scaffold(
      appBar: CaravellaAppBar(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddNewExpensesGroupPage(),
              ),
            );
            if (result == true) {
              await _loadTrips();
            }
          },
          tooltip: loc.get('add_trip'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: Text(
            'Nuovo gruppo',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
      body: Column(
        children: [
          // HEADER SECTION CON RICERCA E FILTRI
          Container(
            child: Column(
              children: [
                // TOP BAR CON SEARCH E FILTER BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      // SEARCH BOX ESPANDIBILE
                      if (_isSearchExpanded)
                        Expanded(
                          child: ExpandableSearchBar(
                            controller: _searchController,
                            isExpanded: _isSearchExpanded,
                            searchQuery: _searchQuery,
                            onToggle: _toggleSearch,
                            onSearchChanged: _onSearchChanged,
                          ),
                        )
                      else
                        ExpandableSearchBar(
                          controller: _searchController,
                          isExpanded: _isSearchExpanded,
                          searchQuery: _searchQuery,
                          onToggle: _toggleSearch,
                          onSearchChanged: _onSearchChanged,
                        ),
                      if (!_isSearchExpanded) ...[
                        const SizedBox(width: 16),
                        // FILTER BUTTON
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _showFilters
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh
                                    .withValues(alpha: 0.8),
                            border: Border.all(
                              color: _showFilters
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.5)
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _toggleFilters,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: _showFilters
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // FILTRI SECTION
                if (_showFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtra per periodo',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _periodOptions.map((option) {
                            final isSelected = _periodFilter == option['key'];
                            return _buildFilterChip(
                              context,
                              option['label'],
                              option['icon'],
                              isSelected,
                              () => _onFilterChanged(option['key']),
                            );
                          }).toList(),
                        ),
                        if (_periodFilter != 'all') ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _onFilterChanged('all'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Rimuovi filtri',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // MAIN CONTENT
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : _filteredTrips.isEmpty
                    ? TripEmptyStates(
                        searchQuery: _searchQuery,
                        periodFilter: _periodFilter,
                        localizations: loc,
                        onTripAdded: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddNewExpensesGroupPage(),
                            ),
                          );
                          if (result == true) {
                            await _loadTrips();
                          }
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = _filteredTrips[index];
                          return TripCard(
                            trip: trip,
                            onTripDeleted: _deleteTrip,
                            onTripOptionsPressed: _showTripOptions,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
