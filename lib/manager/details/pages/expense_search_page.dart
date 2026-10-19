import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../group/widgets/period_selection_bottom_sheet.dart';
import '../widgets/expense_day_row.dart';
import '../widgets/expense_search_empty_state.dart';

/// Search over a group's expenses, in the app's style.
///
/// Full-text across name, note, category, payer, place and amount. Before
/// typing it suggests filters to start from (payer, category, period, with
/// attachment / place); a filters button opens the same choices in a sheet,
/// and active filters stay as removable pills. Results come with their
/// count and total, in one card; a result found only through its place or
/// note says so under the row.
/// Period filters of [ExpenseSearchPage].
enum ExpenseSearchDateFilter { today, last7Days, thisMonth, range }

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

  int get _activeFilterCount =>
      (_selectedStartDate != null && _selectedEndDate != null ? 1 : 0) +
      (_selectedCategoryId != null ? 1 : 0) +
      (_selectedParticipantId != null ? 1 : 0) +
      (_filterHasAttachment ? 1 : 0) +
      (_filterHasLocation ? 1 : 0);

  bool get _showSuggestions =>
      _searchQuery.trim().isEmpty && _activeFilterCount == 0;

  String _dateLabel(gen.AppLocalizations gloc) => switch (_selectedDateFilter) {
    ExpenseSearchDateFilter.today => gloc.today,
    ExpenseSearchDateFilter.last7Days => gloc.last_7_days,
    ExpenseSearchDateFilter.thisMonth => gloc.this_month,
    _ => _formatDateRangeLabel(context),
  };

  /// Filter pills (suggestions before typing, and the filters sheet).
  /// [onChanged] lets the sheet rebuild itself after each tap.
  List<Widget> _filterSections(
    gen.AppLocalizations gloc, {
    VoidCallback? onChanged,
  }) {
    void apply(VoidCallback change) {
      _unfocus();
      setState(change);
      onChanged?.call();
    }

    return [
      PillSection(
        label: gloc.paid_by,
        pills: [
          for (final p in widget.participants)
            FilterPill(
              icon: Icons.person_outline,
              label: p.name,
              selected: _selectedParticipantId == p.id,
              onTap: () => apply(
                () => _selectedParticipantId = _selectedParticipantId == p.id
                    ? null
                    : p.id,
              ),
            ),
        ],
      ),
      PillSection(
        label: gloc.categories,
        pills: [
          for (final c in widget.categories)
            FilterPill(
              label: c.name,
              selected: _selectedCategoryId == c.id,
              onTap: () => apply(
                () => _selectedCategoryId = _selectedCategoryId == c.id
                    ? null
                    : c.id,
              ),
            ),
        ],
      ),
      PillSection(
        label: gloc.period,
        pills: [
          for (final (f, label) in [
            (ExpenseSearchDateFilter.today, gloc.today),
            (ExpenseSearchDateFilter.last7Days, gloc.last_7_days),
            (ExpenseSearchDateFilter.thisMonth, gloc.this_month),
            (ExpenseSearchDateFilter.range, _formatDateRangeLabel(context)),
          ])
            FilterPill(
              icon: f == ExpenseSearchDateFilter.range
                  ? Icons.date_range_outlined
                  : null,
              label: label,
              selected: _selectedDateFilter == f,
              onTap: () {
                _togglePresetFilter(f);
                onChanged?.call();
              },
            ),
        ],
      ),
      PillSection(
        label: gloc.filters,
        pills: [
          FilterPill(
            icon: Icons.attach_file_rounded,
            label: gloc.has_attachment,
            selected: _filterHasAttachment,
            onTap: () =>
                apply(() => _filterHasAttachment = !_filterHasAttachment),
          ),
          FilterPill(
            icon: Icons.place_outlined,
            label: gloc.has_location,
            selected: _filterHasLocation,
            onTap: () => apply(() => _filterHasLocation = !_filterHasLocation),
          ),
        ],
      ),
    ];
  }

  Future<void> _openFilters() async {
    _unfocus();
    final gloc = gen.AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  gloc.filters,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                ..._filterSections(gloc, onChanged: () => setSheet(() {})),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(gloc.show_results(_filteredExpenses.length)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Why [e] matched when the query isn't in its title, category or payer
  /// (shown under the row): its place or its note.
  (IconData, String)? _matchReason(ExpenseDetails e) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return null;
    if ((e.name ?? '').toLowerCase().contains(q) ||
        e.category.name.toLowerCase().contains(q) ||
        e.paidBy.name.toLowerCase().contains(q)) {
      return null;
    }
    final place = e.location?.displayText ?? '';
    if (place.toLowerCase().contains(q)) return (Icons.place_outlined, place);
    final note = e.note ?? '';
    if (note.toLowerCase().contains(q)) return (Icons.notes_rounded, note);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final results = _filteredExpenses;
    final number = NumberFormat(
      '#,##0.00',
      Localizations.localeOf(context).toString(),
    );
    final total = results.fold<double>(0, (t, e) => t + (e.amount ?? 0));

    final activePills = <Widget>[
      if (_selectedStartDate != null && _selectedEndDate != null)
        FilterPill(
          icon: Icons.date_range_outlined,
          label: _dateLabel(gloc),
          selected: true,
          onRemove: () => _setDateFilter(null),
        ),
      for (final p in widget.participants)
        if (p.id == _selectedParticipantId)
          FilterPill(
            icon: Icons.person_outline,
            label: p.name,
            selected: true,
            onRemove: () => setState(() => _selectedParticipantId = null),
          ),
      for (final c in widget.categories)
        if (c.id == _selectedCategoryId)
          FilterPill(
            label: c.name,
            selected: true,
            onRemove: () => setState(() => _selectedCategoryId = null),
          ),
      if (_filterHasAttachment)
        FilterPill(
          icon: Icons.attach_file_rounded,
          label: gloc.has_attachment,
          selected: true,
          onRemove: () => setState(() => _filterHasAttachment = false),
        ),
      if (_filterHasLocation)
        FilterPill(
          icon: Icons.place_outlined,
          label: gloc.has_location,
          selected: true,
          onRemove: () => setState(() => _filterHasLocation = false),
        ),
    ];

    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        backgroundColor: s.surfaceContainer,
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, top + 8, 16, 0),
          child: Column(
            children: [
              SearchTopBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: gloc.search_in_group(widget.groupName),
                onChanged: (value) => setState(() => _searchQuery = value),
                onFilters: _openFilters,
                activeFilters: _activeFilterCount,
                filtersTooltip: gloc.filters,
                clearTooltip: gloc.clear,
              ),
              Expanded(
                child: _showSuggestions
                    ? ListView(
                        padding: EdgeInsets.only(bottom: bottom + 24),
                        children: _filterSections(gloc),
                      )
                    : ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(top: 12, bottom: bottom + 24),
                        children: [
                          if (activePills.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...activePills,
                                if (activePills.length > 1)
                                  FilterPill(
                                    icon: Icons.filter_list_off_rounded,
                                    label: gloc.clear_filters,
                                    onTap: _clearAllFilters,
                                  ),
                              ],
                            ),
                          if (activePills.isNotEmpty)
                            const SizedBox(height: 12),
                          if (results.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: EmptySearchState(
                                hasActiveFilters: _hasActiveFilters,
                              ),
                            )
                          else ...[
                            SearchSummaryBar(
                              count: gloc.expense_count(results.length),
                              total:
                                  '${number.format(total)} ${widget.currency}',
                            ),
                            SettingsGroup(
                              children: [
                                for (final e in results) _resultRow(e),
                              ],
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(ExpenseDetails expense) {
    final theme = Theme.of(context);
    final reason = _matchReason(expense);
    final row = ExpenseDayRow(
      expense: expense,
      currency: widget.currency,
      showMonth: true,
      highlightQuery: _searchQuery.trim().isEmpty ? null : _searchQuery,
      onTap: () {
        _unfocus();
        widget.onExpenseTap(expense);
      },
    );
    if (reason == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        Padding(
          padding: const EdgeInsets.fromLTRB(62, 0, 16, 12),
          child: Row(
            children: [
              Icon(reason.$1, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: HighlightedText(
                  text: reason.$2,
                  query: _searchQuery,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
