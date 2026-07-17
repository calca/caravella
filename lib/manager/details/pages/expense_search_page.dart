import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../group/widgets/period_selection_bottom_sheet.dart';
import '../widgets/expense_search_filter_chips.dart';
import '../widgets/expense_search_empty_state.dart';

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

class _ExpenseSearchPageState extends State<ExpenseSearchPage> {
  static const int _last7DaysCount = 7;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedParticipantId;
  ExpenseSearchDateFilter? _selectedDateFilter;
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
    ExpenseSearchDateFilter? filter, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    setState(() {
      _selectedDateFilter = filter;
      _selectedStartDate = startDate != null ? _normalizeDate(startDate) : null;
      _selectedEndDate = endDate != null ? _normalizeDate(endDate) : null;
    });
  }

  void _togglePresetFilter(ExpenseSearchDateFilter filter) {
    if (filter == ExpenseSearchDateFilter.range) {
      _openRangePicker();
      return;
    }

    if (_selectedDateFilter == filter) {
      _setDateFilter(null);
      return;
    }

    final today = _normalizeDate(DateTime.now());

    switch (filter) {
      case ExpenseSearchDateFilter.today:
        _setDateFilter(filter, startDate: today, endDate: today);
        break;
      case ExpenseSearchDateFilter.last7Days:
        _setDateFilter(
          filter,
          startDate: today.subtract(const Duration(days: _last7DaysCount - 1)),
          endDate: today,
        );
        break;
      case ExpenseSearchDateFilter.thisMonth:
        _setDateFilter(
          filter,
          startDate: DateTime(today.year, today.month, 1),
          endDate: _endOfMonth(today),
        );
        break;
      case ExpenseSearchDateFilter.range:
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
          ExpenseSearchDateFilter.range,
          startDate: startDate,
          endDate: endDate,
        );
      },
    );
  }

  String _formatDateRangeLabel(BuildContext context) {
    if (_selectedDateFilter != ExpenseSearchDateFilter.range ||
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
    final filteredExpenses = _filteredExpenses;

    return Scaffold(
      appBar: SearchAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: gloc.search_in_group(widget.groupName),
        onChanged: (value) => setState(() => _searchQuery = value),
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
      body: Column(
        children: [
          const SizedBox(height: 12),
          SearchFilterSectionLabel(label: gloc.dates),
          const SizedBox(height: 6),
          DateFilterChipsSection(
            todayLabel: gloc.today,
            last7DaysLabel: gloc.last_7_days,
            thisMonthLabel: gloc.this_month,
            rangeLabel: _formatDateRangeLabel(context),
            selectedDateFilter: _selectedDateFilter,
            onTodaySelected: () =>
                _togglePresetFilter(ExpenseSearchDateFilter.today),
            onLast7DaysSelected: () =>
                _togglePresetFilter(ExpenseSearchDateFilter.last7Days),
            onThisMonthSelected: () =>
                _togglePresetFilter(ExpenseSearchDateFilter.thisMonth),
            onRangeSelected: () =>
                _togglePresetFilter(ExpenseSearchDateFilter.range),
          ),

          // Filter chips
          const SizedBox(height: 12),
          SearchFilterSectionLabel(label: gloc.filters),
          const SizedBox(height: 6),
          FilterChipsSection(
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
                ? EmptySearchState(hasActiveFilters: _hasActiveFilters)
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
