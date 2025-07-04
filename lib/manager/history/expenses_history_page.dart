import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/expense_group.dart';
import '../../data/expense_participant.dart';
import '../../data/expense_category.dart';
import '../../../data/expense_group_storage.dart';
import '../details/trip_detail_page.dart';
import '../../app_localizations.dart';
import '../group/add_new_expenses_group.dart';
import '../../state/locale_notifier.dart';
import '../../widgets/caravella_app_bar.dart';
import '../../widgets/currency_display.dart';

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
  late Animation<double> _filterAnimation;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

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
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
    _loadTrips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _filterAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    try {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Smooth transition
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
      if (_isSearchExpanded) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elimina viaggio'),
        content: Text('Vuoi davvero eliminare "${trip.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina')),
        ],
      ),
    );
    if (confirm == true) {
      _allTrips.removeWhere((t) => t.id == trip.id);
      await ExpenseGroupStorage.writeTrips(_allTrips);
      setState(() {
        _filteredTrips = _applyFilter(_allTrips);
      });
    }
  }

  void _showTripOptions(ExpenseGroup trip) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      trip.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildOptionTile(
                      icon: Icons.edit_rounded,
                      title: 'Modifica gruppo',
                      subtitle: 'Modifica nome, date e partecipanti',
                      onTap: () => Navigator.of(context).pop('edit'),
                      context: context,
                    ),
                    _buildOptionTile(
                      icon: Icons.copy_rounded,
                      title: 'Duplica gruppo',
                      subtitle: 'Crea una copia con gli stessi dati',
                      onTap: () => Navigator.of(context).pop('duplicate'),
                      context: context,
                    ),
                    _buildOptionTile(
                      icon: Icons.delete_rounded,
                      title: 'Elimina gruppo',
                      subtitle: 'Rimuovi definitivamente questo gruppo',
                      onTap: () => Navigator.of(context).pop('delete'),
                      context: context,
                      isDestructive: true,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      _navigateAndEditTrip(trip);
    } else if (action == 'duplicate') {
      final newTrip = ExpenseGroup(
        title: "${trip.title} (Copia)",
        expenses: [],
        participants: trip.participants
            .map((p) => ExpenseParticipant(name: p.name))
            .toList(),
        startDate: trip.startDate,
        endDate: trip.endDate,
        currency: trip.currency,
        categories:
            trip.categories.map((c) => ExpenseCategory(name: c.name)).toList(),
      );
      _allTrips.add(newTrip);
      await ExpenseGroupStorage.writeTrips(_allTrips);
      setState(() {
        _filteredTrips = _applyFilter(_allTrips);
      });
    } else if (action == 'delete') {
      await _deleteTrip(trip);
    }
  }

  void _navigateAndEditTrip(ExpenseGroup trip) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNewExpensesGroupPage(trip: trip),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      final trips = await ExpenseGroupStorage.getAllGroups();
      if (!mounted) return;
      setState(() {
        _allTrips = trips;
        _filteredTrips = _applyFilter(trips);
      });
    }
  }

  Widget _buildStatChip(IconData icon, String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHigh
            .withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDestructive ? color : null,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final now = DateTime.now();
    return Scaffold(
      appBar: CaravellaAppBar(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
          // HEADER SECTION CON RICERCA E FILTRI MIGLIORATO
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .shadow
                      .withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // TOP BAR CON SEARCH E FILTER BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      // SEARCH BOX ESPANDIBILE
                      AnimatedBuilder(
                        animation: _searchAnimation,
                        builder: (context, child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: _isSearchExpanded ? MediaQuery.of(context).size.width - 112 : 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: _isSearchExpanded
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: _isSearchExpanded && _searchQuery.isNotEmpty
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                width: _isSearchExpanded && _searchQuery.isNotEmpty ? 2 : 1,
                              ),
                            ),
                            child: _isSearchExpanded 
                                ? TextField(
                                    controller: _searchController,
                                    onChanged: _onSearchChanged,
                                    autofocus: true,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Cerca gruppi...',
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: _searchQuery.isNotEmpty
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                        size: 20,
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_searchQuery.isNotEmpty)
                                            IconButton(
                                              icon: Icon(
                                                Icons.clear_rounded,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                _onSearchChanged('');
                                              },
                                            ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.6),
                                              size: 20,
                                            ),
                                            onPressed: _toggleSearch,
                                          ),
                                        ],
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: _toggleSearch,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      // FILTER TOGGLE BUTTON
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: _toggleFilters,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: _showFilters
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              border: Border.all(
                                color: _showFilters
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedRotation(
                                  turns: _showFilters ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: _showFilters
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                    size: 20,
                                  ),
                                ),
                                if (_periodFilter != 'all')
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _showFilters
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // FILTRI A SCOMPARSA
                SizeTransition(
                  sizeFactor: _filterAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                                        .withOpacity(0.8),
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _periodOptions.map((opt) {
                            final selected = _periodFilter == opt['key'];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: InkWell(
                                onTap: () => _onFilterChanged(opt['key']),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        opt['icon'],
                                        size: 16,
                                        color: selected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        opt['label'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: selected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.8),
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.2),
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
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _filteredTrips.isEmpty
                        ? Center(
                            key: const ValueKey('empty'),
                            child: _searchQuery.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '${loc.get('no_search_results')} "$_searchQuery"',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        loc.get('try_different_search'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.6),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : (_periodFilter == 'all')
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.luggage,
                                            size: 100,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(loc.get('no_trips_found'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            label: Text(loc.get('add_trip')),
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.of(context)
                                                      .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddNewExpensesGroupPage(),
                                                ),
                                              );
                                              if (result == true) {
                                                await _loadTrips();
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                          )
                        : ListView.builder(
                            key: const ValueKey('list'),
                            padding: const EdgeInsets.fromLTRB(
                                16, 8, 16, 100), // Padding per FAB
                            itemCount: _filteredTrips.length,
                            itemBuilder: (context, index) {
                              final trip = _filteredTrips[index];
                              final isFuture =
                                  trip.startDate?.isAfter(now) ?? false;
                              final isPast =
                                  trip.endDate?.isBefore(now) ?? false;
                              final total = trip.expenses.fold<double>(
                                  0, (sum, e) => sum + (e.amount ?? 0));

                              // Colori per stato
                              Color statusColor;
                              IconData statusIcon;
                              String statusText;

                              if (isFuture) {
                                statusColor =
                                    Theme.of(context).colorScheme.tertiary;
                                statusIcon = Icons.schedule_rounded;
                                statusText = 'Futuro';
                              } else if (isPast) {
                                statusColor =
                                    Theme.of(context).colorScheme.outline;
                                statusIcon = Icons.history_rounded;
                                statusText = 'Completato';
                              } else {
                                statusColor =
                                    Theme.of(context).colorScheme.primary;
                                statusIcon = Icons.play_circle_fill_rounded;
                                statusText = 'In corso';
                              }

                              return Dismissible(
                                key: ValueKey(trip.title +
                                    (trip.startDate?.toIso8601String() ??
                                        trip.timestamp.toIso8601String())),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onError,
                                          size: 28),
                                      const SizedBox(height: 4),
                                      Text('Elimina',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError,
                                              )),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(Icons.warning_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                          const SizedBox(width: 12),
                                          const Text('Elimina gruppo'),
                                        ],
                                      ),
                                      content: Text(
                                          'Vuoi davvero eliminare "${trip.title}"?\n\nQuesta azione non può essere annullata.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Annulla')),
                                        FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            child: const Text('Elimina')),
                                      ],
                                    ),
                                  );
                                  return confirm == true;
                                },
                                onDismissed: (_) => _deleteTrip(trip),
                                child: GestureDetector(
                                  onLongPress: () => _showTripOptions(trip),
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .shadow
                                              .withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TripDetailPage(trip: trip),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header con titolo e stato
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    statusIcon,
                                                    color: statusColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        trip.title,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: statusColor
                                                              .withOpacity(0.15),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Text(
                                                          statusText,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelSmall
                                                                  ?.copyWith(
                                                                    color:
                                                                        statusColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Statistiche quick
                                                Row(
                                                  children: [
                                                    _buildStatChip(
                                                      Icons.people_rounded,
                                                      '${trip.participants.length}',
                                                      context,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    _buildStatChip(
                                                      Icons
                                                          .receipt_long_rounded,
                                                      '${trip.expenses.length}',
                                                      context,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Data e partecipanti
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    trip.startDate != null &&
                                                            trip.endDate != null
                                                        ? loc.get('from_to',
                                                            params: {
                                                                'start':
                                                                    '${trip.startDate!.day}/${trip.startDate!.month}/${trip.startDate!.year}',
                                                                'end':
                                                                    '${trip.endDate!.day}/${trip.endDate!.month}/${trip.endDate!.year}'
                                                              })
                                                        : 'Date non definite',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(0.7),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.group_rounded,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    trip.participants.length <= 2
                                                        ? trip.participants.map((p) => p.name).join(', ')
                                                        : '${trip.participants.length} partecipanti',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(0.7),
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            // Totale spese
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.euro_rounded,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Totale spese',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                  const Spacer(),
                                                  CurrencyDisplay(
                                                    value: total,
                                                    currency: trip.currency,
                                                    valueFontSize: 18.0,
                                                    currencyFontSize: 14.0,
                                                    alignment:
                                                        MainAxisAlignment.end,
                                                    showDecimals: true,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
