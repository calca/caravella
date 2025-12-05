import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/widgets/expense_entry_sheet.dart';
import '../../../manager/expense/pages/expense_form_page.dart';
import '../../../manager/expense/state/expense_form_state.dart';
import '../../../manager/details/pages/tabs/usecase/daily_totals_utils.dart';

class GroupCardContent extends StatelessWidget {
  // Design constants
  static const double _titleFontSize = 28.0;
  static const double _totalFontSize = 52.0;
  static const double _currencyFontSize = 32.0;
  static const double _buttonVerticalPadding = 12.0;
  static const double _borderRadius = 12.0;
  static const double _iconSize = 20.0;
  static const double _spacing = 8.0;
  static const double _largSpacing = 24.0;

  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
  });

  String _formatDateRange(ExpenseGroup group, gen.AppLocalizations loc) {
    final start = group.startDate;
    final end = group.endDate;

    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Dal ${_formatDate(start)}';
    } else if (end != null) {
      return 'Fino al ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final currentYear = DateTime.now().year;
    if (date.year == currentYear) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddExpenseSheet(BuildContext context, ExpenseGroup currentGroup) {
    // Salva il riferimento al notifier
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? group;
          return _ExpenseEntrySheetWithState(
            group: currentGroup,
            fullEdit: false,
            showGroupHeader: false,
            onExpenseSaved: (expense) async {
              final sheetCtx = context;
              final nav = Navigator.of(sheetCtx);
              final gloc = gen.AppLocalizations.of(sheetCtx);

              final expenseWithId = expense.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              );

              // Persist using the new storage API
              await ExpenseGroupStorageV2.addExpenseToGroup(
                currentGroup.id,
                expenseWithId,
              );

              // Refresh notifier state and notify UI
              await groupNotifier.refreshGroup();
              groupNotifier.notifyGroupUpdated(currentGroup.id);

              // Check if we should prompt for rating
              RatingService.checkAndPromptForRating();

              if (!sheetCtx.mounted) return;
              AppToast.show(
                sheetCtx,
                gloc.expense_added_success,
                type: ToastType.success,
              );
              nav.pop();
            },
            onCategoryAdded: (categoryName) async {
              await notifier.addCategory(categoryName);
            },
            onExpand: (currentState) {
              // Chiudi il bottom sheet
              Navigator.of(context).pop();
              // Apri la full page con lo stato corrente
              _openFullExpenseForm(context, currentGroup, currentState);
            },
          );
        },
      ),
    ).whenComplete(() {
      // Pulisci il notifier quando il dialog si chiude
      notifier.clearCurrentGroup();
    });
  }

  void _openFullExpenseForm(
    BuildContext context,
    ExpenseGroup currentGroup,
    ExpenseFormState? partialState,
  ) {
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    // Crea un expense parziale dallo stato se presente
    ExpenseDetails? partialExpense;
    if (partialState != null) {
      partialExpense = ExpenseDetails(
        id: null,
        name: partialState.name.isEmpty ? null : partialState.name,
        amount: partialState.amount,
        paidBy: partialState.paidBy!,
        category: partialState.category!,
        date: partialState.date,
        location: partialState.location,
        note: partialState.note.isEmpty ? null : partialState.note,
        attachments: partialState.attachments,
      );
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => Consumer<ExpenseGroupNotifier>(
              builder: (context, groupNotifier, child) {
                final currentGroup = groupNotifier.currentGroup ?? group;
                return ExpenseFormPage(
                  group: currentGroup,
                  initialExpense: partialExpense,
                  onExpenseSaved: (expense) async {
                    final pageCtx = context;
                    final nav = Navigator.of(pageCtx);
                    final gloc = gen.AppLocalizations.of(pageCtx);

                    final expenseWithId = expense.copyWith(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                    );

                    await ExpenseGroupStorageV2.addExpenseToGroup(
                      currentGroup.id,
                      expenseWithId,
                    );

                    await groupNotifier.refreshGroup();
                    groupNotifier.notifyGroupUpdated(currentGroup.id);

                    RatingService.checkAndPromptForRating();

                    if (!pageCtx.mounted) return;
                    AppToast.show(
                      pageCtx,
                      gloc.expense_added_success,
                      type: ToastType.success,
                    );
                    nav.pop();
                  },
                  onCategoryAdded: (categoryName) async {
                    await notifier.addCategory(categoryName);
                  },
                );
              },
            ),
          ),
        )
        .whenComplete(() {
          notifier.clearCurrentGroup();
        });
  }

  // Computed properties memoizzate per performance
  double get totalExpenses => group.expenses.fold<double>(
    0,
    (sum, expense) => sum + (expense.amount ?? 0),
  );

  int get participantCount => group.participants.length;

  double get recentExpensesTotal => group.expenses
      .where(
        (e) => e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))),
      )
      .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseGroupNotifier>(
      builder: (context, groupNotifier, child) {
        // Se questo gruppo è stato aggiornato, usa i dati dal notifier
        final currentGroup = (groupNotifier.currentGroup?.id == group.id)
            ? groupNotifier.currentGroup!
            : group;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currentGroup),
            _buildDateRange(currentGroup),
            _buildTotalAmount(context, currentGroup),
            const SizedBox(height: _largSpacing),
            const Spacer(),
            _buildStatistics(context, currentGroup),
            const SizedBox(height: 24),
            _buildAddButton(context, currentGroup),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ExpenseGroup currentGroup) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            currentGroup.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: _titleFontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRange(ExpenseGroup currentGroup) {
    // Show pin badge even if there are no dates
    if (currentGroup.startDate == null &&
        currentGroup.endDate == null &&
        !currentGroup.pinned) {
      return const SizedBox(height: _spacing);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _spacing),
        Row(
          children: [
            if (currentGroup.startDate != null ||
                currentGroup.endDate != null) ...[
              Icon(
                Icons.event_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatDateRange(currentGroup, localizations),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (currentGroup.pinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.05,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localizations.pin,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: _spacing),
      ],
    );
  }

  Widget _buildTotalAmount(BuildContext context, ExpenseGroup currentGroup) {
    final localizations = gen.AppLocalizations.of(context);
    final totalExpenses = currentGroup.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Semantics(
          label: localizations.accessibility_total_expenses(
            CurrencyDisplay.formatCurrencyText(totalExpenses, '€'),
          ),
          child: CurrencyDisplay(
            value: totalExpenses,
            currency: '€',
            valueFontSize: _totalFontSize,
            currencyFontSize: _currencyFontSize,
            alignment: MainAxisAlignment.end,
            showDecimals: true,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Calculate daily average spending for the group
  double _calculateDailyAverage(ExpenseGroup group) {
    if (group.expenses.isEmpty) return 0.0;

    final now = DateTime.now();
    DateTime startDate, endDate;

    if (group.startDate != null && group.endDate != null) {
      startDate = group.startDate!;
      endDate = group.endDate!.isBefore(now) ? group.endDate! : now;
    } else {
      // If no dates, use first expense to now
      final sortedExpenses = [...group.expenses]
        ..sort((a, b) => a.date.compareTo(b.date));
      startDate = sortedExpenses.first.date;
      endDate = now;
    }

    final days = endDate.difference(startDate).inDays + 1;
    if (days <= 0) return 0.0;

    final totalSpent = group.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );

    return totalSpent / days;
  }

  /// Calculate today's total spending
  double _calculateTodaySpending(ExpenseGroup group) {
    if (group.expenses.isEmpty) return 0.0;
    final now = DateTime.now();
    return group.expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
  }

  Widget _buildExtraInfo(ExpenseGroup group) {
    final dailyAverage = _calculateDailyAverage(group);
    final todaySpending = _calculateTodaySpending(group);
    final textColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Column(
      children: [
        // Daily average
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${localizations.daily_average}: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontSize: 14,
              ),
            ),
            CurrencyDisplay(
              value: dailyAverage,
              currency: group.currency,
              valueFontSize: 14,
              currencyFontSize: 12,
              alignment: MainAxisAlignment.end,
              showDecimals: true,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Today's spending
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${localizations.spent_today}: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontSize: 14,
              ),
            ),
            CurrencyDisplay(
              value: todaySpending,
              currency: group.currency,
              valueFontSize: 14,
              currencyFontSize: 12,
              alignment: MainAxisAlignment.end,
              showDecimals: true,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, ExpenseGroup currentGroup) {
    // Check if we should show date range chart for groups with dates < 1 month
    if (shouldShowDateRangeChart(currentGroup)) {
      return _buildDateRangeStatistics(currentGroup);
    }

    // Default behavior: show weekly + monthly charts
    return _buildDefaultStatistics(context, currentGroup);
  }

  Widget _buildDateRangeStatistics(ExpenseGroup currentGroup) {
    // Usa il metodo adattivo che gestisce sia gruppi con date che senza
    final dailyTotals = buildAdaptiveDateRangeSeries(currentGroup);

    return Column(
      children: [
        // Extra info for short duration trips
        _buildExtraInfo(currentGroup),
        DateRangeExpenseChart(
          dailyTotals: dailyTotals,
          theme: theme,
          badgeText: localizations.dateRangeChartBadge,
          semanticLabel: localizations.dateRangeExpensesChart,
        ),
      ],
    );
  }

  Widget _buildDefaultStatistics(
    BuildContext context,
    ExpenseGroup currentGroup,
  ) {
    // Serie settimanale e mensile tramite helper condivisi
    final dailyTotals = buildWeeklySeries(currentGroup);
    final dailyMonthTotals = buildMonthlySeries(currentGroup);
    final gloc = gen.AppLocalizations.of(context);

    // Statistiche base
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settimana
        WeeklyExpenseChart(
          dailyTotals: dailyTotals,
          theme: theme,
          badgeText: gloc.weeklyChartBadge,
          semanticLabel: gloc.weeklyExpensesChart,
        ),
        const SizedBox(height: 16),
        // Mese
        MonthlyExpenseChart(
          dailyTotals: dailyMonthTotals,
          theme: theme,
          badgeText: gloc.monthlyChartBadge,
          semanticLabel: gloc.monthlyExpensesChart,
        ),
      ],
    );
  }

  // (Funzione ottimizzata spostata in overview_stats_logic.dart per riuso)

  Widget _buildAddButton(BuildContext context, ExpenseGroup currentGroup) {
    final localizations = gen.AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: localizations.accessibility_add_expense,
        child: TextButton(
          onPressed: () => _showAddExpenseSheet(context, currentGroup),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.05,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: _buttonVerticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          child: Icon(
            Icons.add,
            size: _iconSize + 2,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Stateful wrapper for ExpenseEntrySheet to manage form validity
class _ExpenseEntrySheetWithState extends StatefulWidget {
  final ExpenseGroup group;
  final void Function(ExpenseDetails) onExpenseSaved;
  final void Function(String) onCategoryAdded;
  final bool fullEdit;
  final void Function(ExpenseFormState)? onExpand;
  final bool showGroupHeader;

  const _ExpenseEntrySheetWithState({
    required this.group,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.fullEdit = true,
    this.onExpand,
    this.showGroupHeader = true,
  });

  @override
  State<_ExpenseEntrySheetWithState> createState() =>
      _ExpenseEntrySheetWithStateState();
}

class _ExpenseEntrySheetWithStateState
    extends State<_ExpenseEntrySheetWithState> {
  bool _isFormValid = false;

  void _updateFormValidity(bool isValid) {
    if (mounted && _isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpenseEntrySheet(
      group: widget.group,
      onExpenseSaved: widget.onExpenseSaved,
      onCategoryAdded: widget.onCategoryAdded,
      fullEdit: widget.fullEdit,
      onExpand: widget.onExpand,
      showGroupHeader: widget.showGroupHeader,
      onFormValidityChanged: _updateFormValidity,
    );
  }
}
