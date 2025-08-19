import 'package:flutter/material.dart';
import '../../../data/expense_details.dart';
import '../../../data/expense_category.dart';
import '../../../data/expense_participant.dart';
import 'expense_amount_card.dart';

class FilteredExpenseList extends StatefulWidget {
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;
  final List<ExpenseCategory> categories;
  final List<ExpenseParticipant> participants;
  final ValueChanged<bool>? onFiltersVisibilityChanged;

  const FilteredExpenseList({
    super.key,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
    required this.categories,
    required this.participants,
    this.onFiltersVisibilityChanged,
  });

  @override
  State<FilteredExpenseList> createState() => _FilteredExpenseListState();
}

class _FilteredExpenseListState extends State<FilteredExpenseList> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedParticipantId;
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();

  List<ExpenseDetails> get _filteredExpenses {
    List<ExpenseDetails> filtered = List.from(widget.expenses);

    // Apply search filter (name or note)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) {
        final name = expense.name?.toLowerCase() ?? '';
        final note = expense.note?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || note.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((expense) => expense.category.id == _selectedCategoryId)
          .toList();
    }

    // Apply participant filter
    if (_selectedParticipantId != null) {
      filtered = filtered
          .where((expense) => expense.paidBy.id == _selectedParticipantId)
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategoryId != null ||
        _selectedParticipantId != null;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategoryId = null;
      _selectedParticipantId = null;
    });
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _filteredExpenses;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Filter Header with Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Attività${filteredExpenses.length != widget.expenses.length ? ' (${filteredExpenses.length}/${widget.expenses.length})' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 20,
                  ),
                ),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: Icon(Icons.clear, size: 16),
                  label: Text('Pulisci'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                  widget.onFiltersVisibilityChanged?.call(_showFilters);
                },
                tooltip: _showFilters ? 'Nascondi filtri' : 'Mostra filtri',
              ),
            ],
          ),
        ),

        // Filter Controls
        if (_showFilters) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca per nome o nota...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Category Filter
                if (widget.categories.isNotEmpty) ...[
                  Text(
                    'Categoria',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('Tutte'),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                      ...widget.categories.map(
                        (category) => FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected
                                  ? category.id
                                  : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Participant Filter
                if (widget.participants.isNotEmpty) ...[
                  Text(
                    'Pagato da',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('Tutti'),
                        selected: _selectedParticipantId == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedParticipantId = null;
                          });
                        },
                      ),
                      ...widget.participants.map(
                        (participant) => FilterChip(
                          label: Text(participant.name),
                          selected: _selectedParticipantId == participant.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedParticipantId = selected
                                  ? participant.id
                                  : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Expense List
        if (filteredExpenses.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  _hasActiveFilters
                      ? Icons.search_off
                      : Icons.receipt_long_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  _hasActiveFilters
                      ? 'Nessuna spesa trovata con i filtri selezionati'
                      : 'Nessuna spesa ancora aggiunta',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          Column(
            children: [
              ...filteredExpenses.map(
                (expense) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 0,
                  ),
                  child: ExpenseAmountCard(
                    title: expense.name ?? '',
                    coins: (expense.amount ?? 0).toInt(),
                    checked: true,
                    paidBy: expense.paidBy.name,
                    category: expense.category.name,
                    date: expense.date,
                    currency: widget.currency,
                    onTap: () => widget.onExpenseTap(expense),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ],
    );
  }
}
