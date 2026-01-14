import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:intl/intl.dart';
import 'expense_amount_card.dart';
import 'empty_expense_state.dart';

class FilteredExpenseList extends StatefulWidget {
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;
  final List<ExpenseCategory> categories;
  final List<ExpenseParticipant> participants;
  final ValueChanged<bool>? onFiltersVisibilityChanged;
  final VoidCallback? onAddExpense;

  const FilteredExpenseList({
    super.key,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
    required this.categories,
    required this.participants,
    this.onFiltersVisibilityChanged,
    this.onAddExpense,
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

  /// Groups expenses by month and returns a map of month keys to expense lists
  Map<String, List<ExpenseDetails>> _groupExpensesByMonth(
    List<ExpenseDetails> expenses,
  ) {
    final Map<String, List<ExpenseDetails>> grouped = {};
    
    for (final expense in expenses) {
      // Create a key in format "yyyy-MM" for grouping
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(expense);
    }
    
    return grouped;
  }

  /// Formats a month key to a localized month/year string
  String _formatMonthHeader(String monthKey, Locale locale) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final date = DateTime(year, month);
    
    // Use DateFormat to get localized month and year (e.g., "January 2024" or "gennaio 2024")
    final formatter = DateFormat.yMMMM(locale.toString());
    return formatter.format(date);
  }

  /// Builds the expense list with month headers inserted between different months
  List<Widget> _buildExpenseListWithMonthHeaders(
    List<ExpenseDetails> expenses,
  ) {
    if (expenses.isEmpty) return [];

    final locale = Localizations.localeOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final groupedByMonth = _groupExpensesByMonth(expenses);
    
    // Sort month keys in descending order (newest first)
    final sortedMonthKeys = groupedByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final widgets = <Widget>[];

    for (final monthKey in sortedMonthKeys) {
      final monthExpenses = groupedByMonth[monthKey]!;
      
      // Add month header
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            _formatMonthHeader(monthKey, locale),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );

      // Add expenses for this month
      for (final expense in monthExpenses) {
        widgets.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 0,
            ),
            child: ExpenseAmountCard(
              title: expense.name ?? '',
              coins: (expense.amount ?? 0).toInt(),
              checked: true,
              paidBy: expense.paidBy,
              category: expense.category.name,
              date: expense.date,
              currency: widget.currency,
              highlightQuery: _searchQuery.trim().isEmpty
                  ? null
                  : _searchQuery,
              onTap: () => widget.onExpenseTap(expense),
            ),
          ),
        );
      }
    }

    // Add bottom spacing
    widgets.add(const SizedBox(height: 12));

    return widgets;
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
    // Hide header & filter button entirely if no base expenses
    if (widget.expenses.isEmpty && _showFilters) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _showFilters = false;
          _clearAllFilters();
        });
        widget.onFiltersVisibilityChanged?.call(false);
      });
    }

    return Column(
      children: [
        if (widget.expenses.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                  onPressed: () {
                    final next = !_showFilters;
                    setState(() {
                      _showFilters = next;
                      if (!next) _clearAllFilters();
                    });
                    widget.onFiltersVisibilityChanged?.call(next);
                  },
                  tooltip: _showFilters ? gloc.hide_filters : gloc.show_filters,
                ),
              ],
            ),
          ),
        ],

        if (_showFilters && widget.expenses.isNotEmpty) ...[
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                if (widget.categories.isNotEmpty) ...[
                  Text(
                    gloc.category,
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
                            label: gloc.all_categories,
                            selected: _selectedCategoryId == null,
                            onSelected: () =>
                                setState(() => _selectedCategoryId = null),
                          ),
                          const SizedBox(width: 8),
                          ...List.generate(widget.categories.length, (i) {
                            final category = widget.categories[i];
                            return Row(
                              children: [
                                _CategoryParticipantChip(
                                  label: category.name,
                                  selected: _selectedCategoryId == category.id,
                                  onSelected: () => setState(
                                    () => _selectedCategoryId =
                                        _selectedCategoryId == category.id
                                        ? null
                                        : category.id,
                                  ),
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
                            onSelected: () =>
                                setState(() => _selectedParticipantId = null),
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
                                  onSelected: () => setState(
                                    () => _selectedParticipantId =
                                        _selectedParticipantId == participant.id
                                        ? null
                                        : participant.id,
                                  ),
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
          // Enhanced empty state when no expenses exist (not filtered)
          if (!_hasActiveFilters && widget.onAddExpense != null) ...[
            // NOTE: Cannot rely on constraints.maxHeight here because inside a Column
            // in a SliverToBoxAdapter we receive an unbounded (infinite) height which
            // breaks layout if we attempt to use it. Provide a reasonable fixed height
            // so the empty state has space while avoiding unbounded layout assertions.
            Builder(
              builder: (context) {
                final mq = MediaQuery.of(context);
                // Use between 420 and 60% of available height (viewport)
                final target = (mq.size.height * 0.6).clamp(420, 560);
                return SizedBox(
                  height: target.toDouble(),
                  child: EmptyExpenseState(
                    onAddFirstExpense: widget.onAddExpense!,
                  ),
                );
              },
            ),
          ] else ...[
            // Simple empty state for filtered results or when no callback provided
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
          ],
        ] else ...[
          Column(
            children: _buildExpenseListWithMonthHeaders(filteredExpenses),
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
            ? scheme.onSurfaceVariant.withValues(alpha: 0.2)
            : scheme.outlineVariant.withValues(alpha: 0.4),
      ),
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.onSurfaceVariant.withValues(alpha: 0.15),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
