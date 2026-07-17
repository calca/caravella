import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:intl/intl.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'empty_expense_state.dart';

class FilteredExpenseList extends StatefulWidget {
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;
  final VoidCallback? onAddExpense;

  /// ID of the expense that was just added, to animate its insertion
  final String? newlyAddedExpenseId;

  const FilteredExpenseList({
    super.key,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
    this.onAddExpense,
    this.newlyAddedExpenseId,
  });

  @override
  State<FilteredExpenseList> createState() => _FilteredExpenseListState();
}

class _FilteredExpenseListState extends State<FilteredExpenseList>
    with SingleTickerProviderStateMixin {
  // Pagination state
  static const int _initialLoadCount = 100;
  static const int _pageSize = 50;
  int _displayedExpenseCount = _initialLoadCount;
  bool _isLoadingMore = false;

  // Animation state for newly added expenses
  String? _animatingExpenseId;
  late AnimationController _insertAnimationController;
  late Animation<double> _insertAnimation;

  @override
  void initState() {
    super.initState();
    _insertAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _insertAnimation = CurvedAnimation(
      parent: _insertAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Check if there's a newly added expense to animate
    if (widget.newlyAddedExpenseId != null) {
      _animatingExpenseId = widget.newlyAddedExpenseId;
      _insertAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(FilteredExpenseList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if a new expense was added
    if (widget.newlyAddedExpenseId != null &&
        widget.newlyAddedExpenseId != oldWidget.newlyAddedExpenseId) {
      _animatingExpenseId = widget.newlyAddedExpenseId;
      _insertAnimationController.reset();
      _insertAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _insertAnimationController.dispose();
    super.dispose();
  }

  List<ExpenseDetails> get _filteredExpenses {
    final filtered = List<ExpenseDetails>.from(widget.expenses);

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  /// Returns the paginated list of expenses to display
  List<ExpenseDetails> get _paginatedExpenses {
    final filtered = _filteredExpenses;
    // Return only the first N expenses based on current page
    if (filtered.length <= _displayedExpenseCount) {
      return filtered;
    }
    return filtered.sublist(0, _displayedExpenseCount);
  }

  /// Check if there are more expenses to load
  bool get _hasMoreExpenses {
    return _filteredExpenses.length > _displayedExpenseCount;
  }

  /// Load more expenses (called when user scrolls near the end)
  void _loadMoreExpenses() {
    if (_isLoadingMore || !_hasMoreExpenses) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate a small delay for better UX (prevents too rapid loading)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _displayedExpenseCount = (_displayedExpenseCount + _pageSize).clamp(
          0,
          _filteredExpenses.length,
        );
        _isLoadingMore = false;
      });
    });
  }

  /// Groups expenses by month and returns a map of month keys to expense lists
  Map<String, List<ExpenseDetails>> _groupExpensesByMonth(
    List<ExpenseDetails> expenses,
  ) {
    final Map<String, List<ExpenseDetails>> grouped = {};

    for (final expense in expenses) {
      // Create a key in format "yyyy-MM" for grouping
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';

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

    // Get current month key for comparison
    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final widgets = <Widget>[];

    for (var i = 0; i < sortedMonthKeys.length; i++) {
      final monthKey = sortedMonthKeys[i];
      final monthExpenses = groupedByMonth[monthKey]!;
      final isFirstMonth = i == 0;
      final isCurrentMonth = monthKey == currentMonthKey;

      // Add month header (skip if it's the first month and it's the current month)
      if (!(isFirstMonth && isCurrentMonth)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _formatMonthHeader(monthKey, locale).toUpperCase(),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }

      // Add expenses for this month
      for (final expense in monthExpenses) {
        final expenseCard = Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          child: ExpenseAmountCard(
            title: expense.name ?? '',
            amount: expense.amount ?? 0,
            checked: true,
            paidBy: expense.paidBy,
            category: expense.category.name,
            date: expense.date,
            currency: widget.currency,
            highlightQuery: null,
            onTap: () => widget.onExpenseTap(expense),
          ),
        );

        // Apply animation to newly added expense
        if (expense.id == _animatingExpenseId) {
          widgets.add(
            AnimatedBuilder(
              animation: _insertAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset((1 - _insertAnimation.value) * 50, 0),
                  child: Opacity(
                    opacity: _insertAnimation.value,
                    child: Transform.scale(
                      scale: 0.95 + (_insertAnimation.value * 0.05),
                      child: child,
                    ),
                  ),
                );
              },
              child: expenseCard,
            ),
          );
        } else {
          widgets.add(expenseCard);
        }
      }
    }

    // Add "Load More" button if there are more expenses to load
    if (_hasMoreExpenses) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: _isLoadingMore
              ? Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : TextButton.icon(
                  onPressed: _loadMoreExpenses,
                  icon: Icon(Icons.expand_more, size: 20),
                  label: Text(
                    gen.AppLocalizations.of(context).load_more_expenses,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
        ),
      );
    }

    // Add bottom spacing
    widgets.add(const SizedBox(height: 12));

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _filteredExpenses;
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (widget.expenses.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    gloc.activity,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Expense List
        if (filteredExpenses.isEmpty) ...[
          if (widget.onAddExpense != null) ...[
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
            // Simple empty state when no callback provided
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gloc.no_expenses_yet,
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
            children: _buildExpenseListWithMonthHeaders(_paginatedExpenses),
          ),
        ],
      ],
    );
  }
}
