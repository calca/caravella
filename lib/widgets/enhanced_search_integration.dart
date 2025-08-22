import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'package:org_app_caravella/widgets/material3_search_bar.dart';
import 'package:org_app_caravella/widgets/material3_segmented_button.dart';

/// Enhanced version of the existing expandable search bar that integrates
/// the new Material 3 components for improved filtering and search functionality.
class EnhancedExpandableSearchBar extends StatefulWidget {
  final bool isExpanded;
  final String searchQuery;
  final VoidCallback onToggle;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController controller;
  
  /// Additional filtering options
  final List<String> filterOptions;
  final Set<String> selectedFilters;
  final ValueChanged<Set<String>>? onFiltersChanged;

  const EnhancedExpandableSearchBar({
    super.key,
    required this.isExpanded,
    required this.searchQuery,
    required this.onToggle,
    required this.onSearchChanged,
    required this.controller,
    this.filterOptions = const [],
    this.selectedFilters = const {},
    this.onFiltersChanged,
  });

  @override
  State<EnhancedExpandableSearchBar> createState() => _EnhancedExpandableSearchBarState();
}

class _EnhancedExpandableSearchBarState extends State<EnhancedExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(EnhancedExpandableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: widget.isExpanded && widget.filterOptions.isNotEmpty ? 120 : 54,
          child: widget.isExpanded
              ? _buildExpandedSearch(context)
              : _buildCollapsedSearch(context),
        );
      },
    );
  }

  Widget _buildExpandedSearch(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    
    return Column(
      children: [
        // Search bar
        Material3SearchBar(
          controller: widget.controller,
          hintText: gloc.search_groups,
          onChanged: widget.onSearchChanged,
          autoFocus: true,
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _focusNode.requestFocus(),
          ),
          trailing: [
            if (widget.searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onSearchChanged('');
                },
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onToggle,
            ),
          ],
        ),
        
        // Filter segments (if available)
        if (widget.filterOptions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Material3SegmentedButton<String>(
            segments: Material3SegmentHelpers.createTextSegments(
              Map.fromIterable(
                widget.filterOptions,
                key: (item) => item,
                value: (item) => _getFilterLabel(item, context),
              ),
            ),
            selected: widget.selectedFilters,
            multiSelectionEnabled: true,
            emptySelectionAllowed: false,
            expandedWidth: true,
            onSelectionChanged: widget.onFiltersChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildCollapsedSearch(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return IconButton.filledTonal(
      onPressed: widget.onToggle,
      icon: Icon(
        Icons.search_outlined,
        color: widget.searchQuery.isNotEmpty
            ? scheme.primary
            : scheme.onSurface.withValues(alpha: 0.6),
      ),
      style: IconButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        minimumSize: const Size(54, 54),
      ),
    );
  }

  String _getFilterLabel(String filter, BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    
    // Map common filter types to localized labels
    switch (filter.toLowerCase()) {
      case 'all':
        return gloc.all ?? 'All';
      case 'active':
        return gloc.active ?? 'Active';
      case 'completed':
        return gloc.completed ?? 'Completed';
      case 'archived':
        return gloc.archived ?? 'Archived';
      case 'recent':
        return gloc.recent ?? 'Recent';
      case 'favorites':
        return gloc.favorites ?? 'Favorites';
      default:
        return filter;
    }
  }
}

/// Integration example showing how to use the enhanced search bar 
/// in place of the existing ExpandableSearchBar
class SearchBarIntegrationExample extends StatefulWidget {
  const SearchBarIntegrationExample({super.key});

  @override
  State<SearchBarIntegrationExample> createState() => _SearchBarIntegrationExampleState();
}

class _SearchBarIntegrationExampleState extends State<SearchBarIntegrationExample> {
  bool _isSearchExpanded = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedFilters = {'all'};
  
  final List<String> _statusOptions = ['all', 'active', 'completed', 'archived'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Search Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Enhanced search bar with filters
            Row(
              children: [
                const Spacer(),
                EnhancedExpandableSearchBar(
                  controller: _searchController,
                  isExpanded: _isSearchExpanded,
                  searchQuery: _searchQuery,
                  onToggle: () {
                    setState(() {
                      _isSearchExpanded = !_isSearchExpanded;
                    });
                  },
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  filterOptions: _statusOptions,
                  selectedFilters: _selectedFilters,
                  onFiltersChanged: (filters) {
                    setState(() {
                      _selectedFilters = filters;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Display current state
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current State:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Search Query: "$_searchQuery"'),
                    Text('Selected Filters: ${_selectedFilters.join(", ")}'),
                    Text('Search Expanded: $_isSearchExpanded'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}