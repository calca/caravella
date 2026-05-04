import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String groupName;
  final void Function(ExpenseDetails) onExpenseTap;

  const ExpenseSearchPage({
    super.key,
    required this.expenses,
    required this.categories,
    required this.participants,
    required this.currency,
    required this.groupName,
    required this.onExpenseTap,
  });

  /// Opens the search page and returns the tapped expense (if any).
  static Future<void> show(
    BuildContext context, {
    required List<ExpenseDetails> expenses,
    required List<ExpenseCategory> categories,
    required List<ExpenseParticipant> participants,
    required String currency,
    required String groupName,
    required void Function(ExpenseDetails) onExpenseTap,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseSearchPage(
          expenses: expenses,
          categories: categories,
          participants: participants,
          currency: currency,
          groupName: groupName,
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
      if (mounted) {
        _searchFocusNode.requestFocus();
        _scrollToTargetDate();
      }
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
  ///
  /// Always produces at least 14 days (2 weeks) so the calendar strip is
  /// never too narrow.
  void _computeCalendarDates() {
    final dateSet = <DateTime>{};
    for (final e in widget.expenses) {
      dateSet.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    _expenseDateSet = dateSet;

    // Base range: from the earliest to the latest expense date.
    // Fall back to today when there are no expenses.
    final DateTime rangeStart;
    final DateTime rangeEnd;
    if (dateSet.isEmpty) {
      final now = DateTime.now();
      rangeStart = DateTime(now.year, now.month, now.day);
      rangeEnd = rangeStart;
    } else {
      final sorted = dateSet.toList()..sort();
      rangeStart = sorted.first;
      rangeEnd = sorted.last;
    }

    // Build a continuous range from rangeStart to rangeEnd.
    final dates = <DateTime>[];
    var current = rangeStart;
    while (!current.isAfter(rangeEnd)) {
      dates.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }

    // Ensure a minimum of 14 days (2 full rows of 7).
    while (dates.length < 14) {
      final last = dates.last;
      dates.add(DateTime(last.year, last.month, last.day + 1));
    }

    _calendarDates = dates;
  }

  /// Scrolls the calendar strip so that today (if within the displayed range)
  /// is centred.  If today is outside the range, centres the most recent date.
  void _scrollToTargetDate() {
    if (_calendarDates.isEmpty || !_dateScrollController.hasClients) return;

    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);

    // Pick today when it falls inside the calendar range, otherwise the last
    // displayed date (most recent).
    final DateTime target;
    if (!todayNorm.isBefore(_calendarDates.first) &&
        !todayNorm.isAfter(_calendarDates.last)) {
      target = todayNorm;
    } else {
      target = _calendarDates.last;
    }

    // The calendar is split into two rows at the midpoint.  A date at index i
    // appears in column (i) for row-1 or column (i - midpoint) for row-2.
    // Both rows share the same horizontal scroll, so we compute the column
    // position within whichever row the target date sits in.
    final midpoint = (_calendarDates.length / 2).ceil();
    final idx = _calendarDates.indexWhere(
      (d) =>
          d.year == target.year &&
          d.month == target.month &&
          d.day == target.day,
    );
    if (idx == -1) return;

    final col = idx < midpoint ? idx : idx - midpoint;

    // Each cell: 48 px wide + 2 × 2 px horizontal margin = 52 px.
    // Inner horizontal padding of the scroll content: 8 px on each side.
    const cellWidth = 52.0;
    const hPadding = 8.0;

    final viewport = _dateScrollController.position.viewportDimension;
    final maxScroll = _dateScrollController.position.maxScrollExtent;

    final offset = (hPadding + col * cellWidth + cellWidth / 2 - viewport / 2)
        .clamp(0.0, maxScroll);

    _dateScrollController.jumpTo(offset);
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

  void _unfocus() => _searchFocusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final filteredExpenses = _filteredExpenses;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: gloc.search_in_group(widget.groupName),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : _hasActiveFilters
                  ? IconButton(
                      icon: const Icon(Icons.filter_list_off_rounded, size: 20),
                      onPressed: _clearAllFilters,
                      tooltip: gloc.clear_filters,
                    )
                  : null,
              filled: true,
              fillColor: appBarColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              isDense: false,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
            cursorColor: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          // Date calendar strip (2-row, scrollable)
          if (_calendarDates.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DateCalendarStrip(
              dates: _calendarDates,
              expenseDates: _expenseDateSet,
              selectedDate: _selectedDate,
              scrollController: _dateScrollController,
              onDateSelected: (date) {
                _unfocus();
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
              _unfocus();
              setState(() {
                _selectedCategoryId = _selectedCategoryId == id ? null : id;
              });
            },
            onParticipantSelected: (id) {
              _unfocus();
              setState(() {
                _selectedParticipantId = _selectedParticipantId == id
                    ? null
                    : id;
              });
            },
            onHasAttachmentToggled: () {
              _unfocus();
              setState(() => _filterHasAttachment = !_filterHasAttachment);
            },
            onHasLocationToggled: () {
              _unfocus();
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
                        onTap: () {
                          _unfocus();
                          widget.onExpenseTap(expense);
                        },
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
            // Participant chips (paid by)
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
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: scheme.onSurface.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
      ),
      child: FilterChip(
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
      ),
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
