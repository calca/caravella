import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_details.dart';
import '../../../data/model/expense_category.dart';
import '../../../data/model/expense_participant.dart';
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
    final gloc = gen.AppLocalizations.of(context);
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
                  '${gloc.activity}${filteredExpenses.length != widget.expenses.length ? ' (${filteredExpenses.length}/${widget.expenses.length})' : ''}',
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
                  label: Text(gloc.clear_filters),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              IconButton(
                icon: Icon(
                  _showFilters
                      ? Icons.filter_list_off_outlined
                      : Icons.filter_list_outlined,
                  size: 20,
                ),
                onPressed: widget.expenses.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                        widget.onFiltersVisibilityChanged?.call(_showFilters);
                      },
                tooltip: _showFilters ? gloc.hide_filters : gloc.show_filters,
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
                    hintText: gloc.search_expenses_hint,
                    prefixIcon: Icon(Icons.search_outlined, size: 20),
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
                    gloc.category,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40, // ensure enough height for chips
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _CategoryParticipantChip(
                            label: gloc.all_categories,
                            selected: _selectedCategoryId == null,
                            onSelected: () {
                              setState(() => _selectedCategoryId = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(widget.categories.length, (i) {
                            final category = widget.categories[i];
                            return Row(
                              children: [
                                _CategoryParticipantChip(
                                  label: category.name,
                                  selected: _selectedCategoryId == category.id,
                                  onSelected: () {
                                    setState(
                                      () => _selectedCategoryId =
                                          _selectedCategoryId == category.id
                                          ? null
                                          : category.id,
                                    );
                                  },
                                ),
                                if (i != widget.categories.length - 1)
                                  const SizedBox(width: 8),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Participant Filter
                if (widget.participants.isNotEmpty) ...[
                  Text(
                    gloc.paid_by,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _CategoryParticipantChip(
                            label: gloc.all_participants,
                            selected: _selectedParticipantId == null,
                            onSelected: () {
                              setState(() => _selectedParticipantId = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(widget.participants.length, (i) {
                            final participant = widget.participants[i];
                            return Row(
                              children: [
                                _CategoryParticipantChip(
                                  label: participant.name,
                                  selected:
                                      _selectedParticipantId == participant.id,
                                  onSelected: () {
                                    setState(
                                      () => _selectedParticipantId =
                                          _selectedParticipantId ==
                                              participant.id
                                          ? null
                                          : participant.id,
                                    );
                                  },
                                ),
                                if (i != widget.participants.length - 1)
                                  const SizedBox(width: 8),
                              ],
                            );
                          }),
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

        // Expense List
        if (filteredExpenses.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  _hasActiveFilters
                      ? Icons.search_off_outlined
                      : Icons.receipt_long_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  _hasActiveFilters
                      ? gloc.no_expenses_with_filters
                      : gloc.no_expenses_yet,
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
                    highlightQuery:
                        _searchQuery.trim().isEmpty ? null : _searchQuery,
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

class _CategoryParticipantChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _CategoryParticipantChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      side: BorderSide(
        color: selected
            ? scheme.primaryFixedDim
            : scheme.outlineVariant.withValues(alpha: 0.4),
      ),
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.primaryFixedDim,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
