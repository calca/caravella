import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../group/widgets/period_selection_bottom_sheet.dart';
import '../widgets/expense_amount_card.dart';

/// Full-screen search page for expenses within a group.
///
/// Features:
/// - Full-text search across all expense fields (name, note, category, paidBy,
///   location, amount)
/// - Quick date filter chips with reusable range picker
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

enum _ExpenseSearchDateFilter { today, last7Days, thisMonth, range }

class _ExpenseSearchPageState extends State<ExpenseSearchPage> {
  static const int _last7DaysCount = 7;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedParticipantId;
  _ExpenseSearchDateFilter? _selectedDateFilter;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _filterHasAttachment = false;
  bool _filterHasLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfMonth(DateTime date) {
    final firstDayOfNextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1));
  }

  void _setDateFilter(
    _ExpenseSearchDateFilter? filter, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    setState(() {
      _selectedDateFilter = filter;
      _selectedStartDate = startDate != null ? _normalizeDate(startDate) : null;
      _selectedEndDate = endDate != null ? _normalizeDate(endDate) : null;
    });
  }

  void _togglePresetFilter(_ExpenseSearchDateFilter filter) {
    if (filter == _ExpenseSearchDateFilter.range) {
      _openRangePicker();
      return;
    }

    if (_selectedDateFilter == filter) {
      _setDateFilter(null);
      return;
    }

    final today = _normalizeDate(DateTime.now());

    switch (filter) {
      case _ExpenseSearchDateFilter.today:
        _setDateFilter(filter, startDate: today, endDate: today);
        break;
      case _ExpenseSearchDateFilter.last7Days:
        _setDateFilter(
          filter,
          startDate: today.subtract(const Duration(days: _last7DaysCount - 1)),
          endDate: today,
        );
        break;
      case _ExpenseSearchDateFilter.thisMonth:
        _setDateFilter(
          filter,
          startDate: DateTime(today.year, today.month, 1),
          endDate: _endOfMonth(today),
        );
        break;
      case _ExpenseSearchDateFilter.range:
        break;
    }
  }

  Future<void> _openRangePicker() async {
    _unfocus();
    await showPeriodSelectionBottomSheet(
      context: context,
      initialStartDate: _selectedStartDate,
      initialEndDate: _selectedEndDate,
      onSelectionChanged: (startDate, endDate) {
        if (startDate == null || endDate == null) {
          return;
        }
        _setDateFilter(
          _ExpenseSearchDateFilter.range,
          startDate: startDate,
          endDate: endDate,
        );
      },
    );
  }

  String _formatDateRangeLabel(BuildContext context) {
    if (_selectedDateFilter != _ExpenseSearchDateFilter.range ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      return gen.AppLocalizations.of(context).select_period;
    }

    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.Md(locale);
    return '${formatter.format(_selectedStartDate!)} - '
        '${formatter.format(_selectedEndDate!)}';
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
    if (_selectedStartDate != null && _selectedEndDate != null) {
      filtered = filtered.where((expense) {
        final expenseDate = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        return !expenseDate.isBefore(_selectedStartDate!) &&
            !expenseDate.isAfter(_selectedEndDate!);
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
        (_selectedStartDate != null && _selectedEndDate != null) ||
        _selectedCategoryId != null ||
        _selectedParticipantId != null ||
        _filterHasAttachment ||
        _filterHasLocation;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDateFilter = null;
      _selectedStartDate = null;
      _selectedEndDate = null;
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
    final appBarColor = FormTheme.getGmailAppBarSearchBackground(colorScheme);
    final searchBackgroundColor = appBarColor;

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
            decoration: FormTheme.getSearchPillDecoration(
              backgroundColor: searchBackgroundColor,
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
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
            cursorColor: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _SearchFilterSectionLabel(label: gloc.dates),
          const SizedBox(height: 6),
          _DateFilterChipsSection(
            todayLabel: gloc.today,
            last7DaysLabel: gloc.last_7_days,
            thisMonthLabel: gloc.this_month,
            rangeLabel: _formatDateRangeLabel(context),
            selectedDateFilter: _selectedDateFilter,
            onTodaySelected: () =>
                _togglePresetFilter(_ExpenseSearchDateFilter.today),
            onLast7DaysSelected: () =>
                _togglePresetFilter(_ExpenseSearchDateFilter.last7Days),
            onThisMonthSelected: () =>
                _togglePresetFilter(_ExpenseSearchDateFilter.thisMonth),
            onRangeSelected: () =>
                _togglePresetFilter(_ExpenseSearchDateFilter.range),
          ),

          // Filter chips
          const SizedBox(height: 12),
          _SearchFilterSectionLabel(label: gloc.filters),
          const SizedBox(height: 6),
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
// Date filter chips
// ---------------------------------------------------------------------------

class _DateFilterChipsSection extends StatelessWidget {
  final String todayLabel;
  final String last7DaysLabel;
  final String thisMonthLabel;
  final String rangeLabel;
  final _ExpenseSearchDateFilter? selectedDateFilter;
  final VoidCallback onTodaySelected;
  final VoidCallback onLast7DaysSelected;
  final VoidCallback onThisMonthSelected;
  final VoidCallback onRangeSelected;

  const _DateFilterChipsSection({
    required this.todayLabel,
    required this.last7DaysLabel,
    required this.thisMonthLabel,
    required this.rangeLabel,
    required this.selectedDateFilter,
    required this.onTodaySelected,
    required this.onLast7DaysSelected,
    required this.onThisMonthSelected,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SearchFilterChip(
                label: todayLabel,
                selected: selectedDateFilter == _ExpenseSearchDateFilter.today,
                onSelected: onTodaySelected,
                icon: Icons.today_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SearchFilterChip(
                label: last7DaysLabel,
                selected:
                    selectedDateFilter == _ExpenseSearchDateFilter.last7Days,
                onSelected: onLast7DaysSelected,
                icon: Icons.history_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SearchFilterChip(
                label: thisMonthLabel,
                selected:
                    selectedDateFilter == _ExpenseSearchDateFilter.thisMonth,
                onSelected: onThisMonthSelected,
                icon: Icons.calendar_month_outlined,
              ),
            ),
            _SearchFilterChip(
              label: rangeLabel,
              selected: selectedDateFilter == _ExpenseSearchDateFilter.range,
              onSelected: onRangeSelected,
              icon: Icons.date_range_outlined,
            ),
          ],
        ),
      ),
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

class _SearchFilterSectionLabel extends StatelessWidget {
  final String label;

  const _SearchFilterSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
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
