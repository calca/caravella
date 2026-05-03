import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/expense_amount_card.dart';

/// Full-screen search page for expenses within a group.
///
/// Features:
/// - Full-text search across all expense fields (name, note, category, paidBy,
///   location, amount)
/// - 2-row scrollable date calendar (2 weeks visible) for quick date filtering
/// - Category and paid-by filter chips
/// - Has-attachment and has-location toggle filters
/// - Results displayed using [ExpenseAmountCard]
class ExpenseSearchPage extends StatefulWidget {
  final List<ExpenseDetails> expenses;
  final List<ExpenseCategory> categories;
  final List<ExpenseParticipant> participants;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;

  const ExpenseSearchPage({
    super.key,
    required this.expenses,
    required this.categories,
    required this.participants,
    required this.currency,
    required this.onExpenseTap,
  });

  /// Opens the search page and returns the tapped expense (if any).
  static Future<void> show(
    BuildContext context, {
    required List<ExpenseDetails> expenses,
    required List<ExpenseCategory> categories,
    required List<ExpenseParticipant> participants,
    required String currency,
    required void Function(ExpenseDetails) onExpenseTap,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseSearchPage(
          expenses: expenses,
          categories: categories,
          participants: participants,
          currency: currency,
          onExpenseTap: onExpenseTap,
        ),
      ),
    );
  }

  @override
  State<ExpenseSearchPage> createState() => _ExpenseSearchPageState();
}

class _ExpenseSearchPageState extends State<ExpenseSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedParticipantId;
  DateTime? _selectedDate;
  bool _filterHasAttachment = false;
  bool _filterHasLocation = false;

  /// Set of dates (day-level) that have expenses – used for highlighting.
  late Set<DateTime> _expenseDateSet;

  /// Continuous range of dates from earliest to latest expense.
  late List<DateTime> _calendarDates;

  /// The scroll controller for the date calendar strip.
  final ScrollController _dateScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _computeCalendarDates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _dateScrollController.dispose();
    super.dispose();
  }

  /// Builds a continuous date range and the set of dates with expenses.
  void _computeCalendarDates() {
    final dateSet = <DateTime>{};
    for (final e in widget.expenses) {
      dateSet.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    _expenseDateSet = dateSet;

    if (dateSet.isEmpty) {
      _calendarDates = [];
      return;
    }

    final sorted = dateSet.toList()..sort();
    final first = sorted.first;
    final last = sorted.last;

    // Build a continuous range from first to last date
    final dates = <DateTime>[];
    var current = first;
    while (!current.isAfter(last)) {
      dates.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }
    _calendarDates = dates;
  }

  /// Filtered expense list based on all active filters.
  List<ExpenseDetails> get _filteredExpenses {
    List<ExpenseDetails> filtered = List.from(widget.expenses);

    // Full-text search across all fields
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((expense) {
        final name = expense.name?.toLowerCase() ?? '';
        final note = expense.note?.toLowerCase() ?? '';
        final category = expense.category.name.toLowerCase();
        final paidBy = expense.paidBy.name.toLowerCase();
        final location = expense.location?.displayText.toLowerCase() ?? '';
        final amount = expense.amount?.toString() ?? '';
        return name.contains(query) ||
            note.contains(query) ||
            category.contains(query) ||
            paidBy.contains(query) ||
            location.contains(query) ||
            amount.contains(query);
      }).toList();
    }

    // Date filter
    if (_selectedDate != null) {
      filtered = filtered.where((expense) {
        final ed = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        return ed == _selectedDate;
      }).toList();
    }

    // Category filter
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((e) => e.category.id == _selectedCategoryId)
          .toList();
    }

    // Participant filter
    if (_selectedParticipantId != null) {
      filtered = filtered
          .where((e) => e.paidBy.id == _selectedParticipantId)
          .toList();
    }

    // Has attachment filter
    if (_filterHasAttachment) {
      filtered = filtered.where((e) => e.attachments.isNotEmpty).toList();
    }

    // Has location filter
    if (_filterHasLocation) {
      filtered = filtered
          .where((e) => e.location?.hasLocation ?? false)
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedDate != null ||
        _selectedCategoryId != null ||
        _selectedParticipantId != null ||
        _filterHasAttachment ||
        _filterHasLocation;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDate = null;
      _selectedCategoryId = null;
      _selectedParticipantId = null;
      _filterHasAttachment = false;
      _filterHasLocation = false;
    });
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final filteredExpenses = _filteredExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.search_expenses),
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear, size: 16),
              label: Text(gloc.clear_filters),
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: gloc.search_all_fields_hint,
                prefixIcon: const Icon(Icons.search_outlined, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
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
          ),

          // Date calendar strip (2-row, scrollable)
          if (_calendarDates.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DateCalendarStrip(
              dates: _calendarDates,
              expenseDates: _expenseDateSet,
              selectedDate: _selectedDate,
              scrollController: _dateScrollController,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = _selectedDate == date ? null : date;
                });
              },
            ),
          ],

          // Filter chips
          const SizedBox(height: 8),
          _FilterChipsSection(
            categories: widget.categories,
            participants: widget.participants,
            selectedCategoryId: _selectedCategoryId,
            selectedParticipantId: _selectedParticipantId,
            filterHasAttachment: _filterHasAttachment,
            filterHasLocation: _filterHasLocation,
            onCategorySelected: (id) {
              setState(() {
                _selectedCategoryId = _selectedCategoryId == id ? null : id;
              });
            },
            onParticipantSelected: (id) {
              setState(() {
                _selectedParticipantId = _selectedParticipantId == id
                    ? null
                    : id;
              });
            },
            onHasAttachmentToggled: () {
              setState(() => _filterHasAttachment = !_filterHasAttachment);
            },
            onHasLocationToggled: () {
              setState(() => _filterHasLocation = !_filterHasLocation);
            },
          ),

          const SizedBox(height: 4),

          // Results
          Expanded(
            child: filteredExpenses.isEmpty
                ? _EmptySearchState(hasActiveFilters: _hasActiveFilters)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return ExpenseAmountCard(
                        title: expense.name ?? '',
                        amount: expense.amount ?? 0,
                        checked: true,
                        paidBy: expense.paidBy,
                        category: expense.category.name,
                        date: expense.date,
                        currency: widget.currency,
                        highlightQuery: _searchQuery.trim().isEmpty
                            ? null
                            : _searchQuery,
                        onTap: () => widget.onExpenseTap(expense),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date calendar strip – shows 2 rows of date cells, scrollable horizontally
// ---------------------------------------------------------------------------

class _DateCalendarStrip extends StatelessWidget {
  final List<DateTime> dates;
  final Set<DateTime> expenseDates;
  final DateTime? selectedDate;
  final ScrollController scrollController;
  final ValueChanged<DateTime> onDateSelected;

  const _DateCalendarStrip({
    required this.dates,
    required this.expenseDates,
    required this.selectedDate,
    required this.scrollController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    // Split dates into two rows for the 2-row calendar
    final int midpoint = (dates.length / 2).ceil();
    final row1 = dates.sublist(0, midpoint);
    final row2 = dates.sublist(midpoint);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(row1, colorScheme, locale, context),
              const SizedBox(height: 4),
              _buildRow(row2, colorScheme, locale, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    List<DateTime> rowDates,
    ColorScheme colorScheme,
    Locale locale,
    BuildContext context,
  ) {
    if (rowDates.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rowDates.map((date) {
        final isSelected =
            selectedDate != null &&
            date.year == selectedDate!.year &&
            date.month == selectedDate!.month &&
            date.day == selectedDate!.day;

        final hasExpenses = expenseDates.contains(date);

        final dayName = DateFormat.E(locale.toString()).format(date);
        final dayNum = date.day.toString();

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : hasExpenses
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dayNum,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: hasExpenses ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : hasExpenses
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 3),
                // Expense indicator dot
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasExpenses
                        ? (isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary)
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips section – categories, participants, attachment, location
// ---------------------------------------------------------------------------

class _FilterChipsSection extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final List<ExpenseParticipant> participants;
  final String? selectedCategoryId;
  final String? selectedParticipantId;
  final bool filterHasAttachment;
  final bool filterHasLocation;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onParticipantSelected;
  final VoidCallback onHasAttachmentToggled;
  final VoidCallback onHasLocationToggled;

  const _FilterChipsSection({
    required this.categories,
    required this.participants,
    required this.selectedCategoryId,
    required this.selectedParticipantId,
    required this.filterHasAttachment,
    required this.filterHasLocation,
    required this.onCategorySelected,
    required this.onParticipantSelected,
    required this.onHasAttachmentToggled,
    required this.onHasLocationToggled,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Category chips
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _SearchFilterChip(
                  label: cat.name,
                  selected: selectedCategoryId == cat.id,
                  onSelected: () => onCategorySelected(cat.id),
                ),
              ),
            ),

            // Participant chips
            ...participants.map(
              (p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _SearchFilterChip(
                  label: p.name,
                  selected: selectedParticipantId == p.id,
                  onSelected: () => onParticipantSelected(p.id),
                  icon: Icons.person_outline,
                ),
              ),
            ),

            // Has attachment chip
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SearchFilterChip(
                label: gloc.has_attachment,
                selected: filterHasAttachment,
                onSelected: onHasAttachmentToggled,
                icon: Icons.attach_file_outlined,
              ),
            ),

            // Has location chip
            _SearchFilterChip(
              label: gloc.has_location,
              selected: filterHasLocation,
              onSelected: onHasLocationToggled,
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable filter chip matching existing style
// ---------------------------------------------------------------------------

class _SearchFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  const _SearchFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            )
          : null,
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

// ---------------------------------------------------------------------------
// Empty search state
// ---------------------------------------------------------------------------

class _EmptySearchState extends StatelessWidget {
  final bool hasActiveFilters;

  const _EmptySearchState({required this.hasActiveFilters});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilters
                  ? Icons.search_off_outlined
                  : Icons.search_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters ? gloc.search_no_results : gloc.search_expenses,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 8),
              Text(
                gloc.search_no_results_hint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
