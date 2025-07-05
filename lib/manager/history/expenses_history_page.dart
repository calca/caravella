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
  String _statusFilter = 'active'; // active, all, archived
  String _searchQuery = '';
  bool _loading = true;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final List<Map<String, dynamic>> _statusOptions = [
    {'key': 'active', 'label': 'Attivi', 'icon': Icons.play_circle_fill_rounded},
    {'key': 'all', 'label': 'Tutti', 'icon': Icons.all_inclusive},
    {'key': 'archived', 'label': 'Archiviati', 'icon': Icons.archive_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
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
    // Applica solo il filtro di ricerca per titolo
    if (_searchQuery.isEmpty) {
      return trips;
    }

    return trips
        .where((trip) =>
            trip.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onStatusFilterChanged(String key) {
    setState(() {
      _statusFilter = key;
    });
    _loadTrips(); // Ricarica i dati con il nuovo filtro
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

  Widget _buildStatusFilterButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
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
          // HEADER SECTION CON FILTRI E RICERCA
          Container(
            child: Column(
              children: [
                // STATUS FILTER BUTTONS
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: _statusOptions.map((option) {
                      final isSelected = _statusFilter == option['key'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildStatusFilterButton(
                            context,
                            option['label'],
                            option['icon'],
                            isSelected,
                            () => _onStatusFilterChanged(option['key']),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                    ],
                  ),
                ),
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
                        periodFilter: _statusFilter,
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
