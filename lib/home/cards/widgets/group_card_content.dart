import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
import '../../../data/expense_group.dart';
import '../../../data/expense_category.dart';
import '../../../data/expense_group_storage.dart';
import '../../../manager/expense/expense_form_component.dart';
import '../../../manager/group/add_new_expenses_group.dart';
import '../../../widgets/currency_display.dart';
import 'mini_expense_chart.dart';

class GroupCardContent extends StatelessWidget {
  // Design constants
  static const double _titleFontSize = 28.0;
  static const double _totalFontSize = 52.0;
  static const double _currencyFontSize = 32.0;
  static const double _chartHeight = 60.0;
  static const double _buttonVerticalPadding = 12.0;
  static const double _borderRadius = 12.0;
  static const double _iconSize = 20.0;
  static const double _spacing = 8.0;
  static const double _largSpacing = 24.0;
  static const double _sectionSpacing = 28.0;

  final ExpenseGroup group;
  final AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;
  final VoidCallback? onUpdated; // Add this missing callback

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
    this.onUpdated, // Add this parameter
  });

  String _formatDateRange(ExpenseGroup group, AppLocalizations loc) {
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

  Future<void> _saveExpenseToGroup(dynamic expense) async {
    try {
      final groups = await ExpenseGroupStorage.getAllGroups();
      final groupIndex = groups.indexWhere((g) => g.id == group.id);

      if (groupIndex != -1) {
        // Add the expense to the group
        groups[groupIndex].expenses.add(expense);

        // Save the updated groups back to storage
        await ExpenseGroupStorage.writeTrips(groups);
      }
    } catch (e) {
      // Handle error gracefully - could show a snackbar in a real app
      debugPrint('Error saving expense: $e');
    }
  }

  Future<void> _saveCategoryToGroup(String newCategory) async {
    try {
      final groups = await ExpenseGroupStorage.getAllGroups();
      final groupIndex = groups.indexWhere((g) => g.id == group.id);

      if (groupIndex != -1) {
        // Check if category already exists
        final existingCategories =
            groups[groupIndex].categories.map((c) => c.name).toList();
        if (!existingCategories.contains(newCategory)) {
          // Add the new category to the group
          final updatedCategories = [...groups[groupIndex].categories];
          updatedCategories.add(ExpenseCategory(name: newCategory));
          groups[groupIndex] =
              groups[groupIndex].copyWith(categories: updatedCategories);

          // Save the updated groups back to storage
          await ExpenseGroupStorage.writeTrips(groups);
        }
      }
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error saving category: $e');
    }
  }

  void _showAddExpenseSheet(BuildContext context) {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar fisso
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.get('add_expense'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Contenuto scrollabile
            Flexible(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        MediaQuery.of(context).padding.bottom +
                        20,
                  ),
                  child: ExpenseFormComponent(
                    participants:
                        group.participants.map((p) => p.name).toList(),
                    categories: group.categories.map((c) => c.name).toList(),
                    onExpenseAdded: (expense) async {
                      // Save the expense to the group
                      await _saveExpenseToGroup(expense);
                      if (context.mounted) {
                        // Brief delay per permettere all'utente di vedere il feedback
                        await Future.delayed(const Duration(milliseconds: 100));
                        Navigator.pop(context);
                      }
                      // Callback per aggiornare la UI, mantenendo la posizione corrente
                      onExpenseAdded();
                    },
                    onCategoryAdded: (newCategory) async {
                      // Save the new category to the group
                      await _saveCategoryToGroup(newCategory);
                      // Notify parent that category was added
                      if (onCategoryAdded != null) {
                        onCategoryAdded!();
                      }
                    },
                    shouldAutoClose: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Computed properties memoizzate per performance
  double get totalExpenses => group.expenses
      .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));

  int get participantCount => group.participants.length;

  double get recentExpensesTotal => group.expenses
      .where((e) =>
          e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
      .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildDateRange(),
        _buildTotalAmount(),
        SizedBox(height: _largSpacing),
        _buildStatistics(),
        _buildRecentActivity(),
        const Spacer(),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            group.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: _titleFontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (group.pinned)
          Icon(
            Icons.push_pin,
            size: _iconSize,
            color: theme.colorScheme.onSurface,
          ),
      ],
    );
  }

  Widget _buildDateRange() {
    if (group.startDate == null && group.endDate == null) {
      return SizedBox(height: _spacing);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _spacing),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDateRange(group, localizations),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: _spacing),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Semantics(
          label: 'Total expenses: ${totalExpenses.toStringAsFixed(2)}€',
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

  Widget _buildStatistics() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Participants: $participantCount',
          child: _buildCompactStat(
            icon: Icons.people_outline,
            value: participantCount.toString(),
          ),
        ),
        const SizedBox(width: 16),
        Semantics(
          label: 'Expenses: ${group.expenses.length}',
          child: _buildCompactStat(
            icon: Icons.receipt_long_outlined,
            value: group.expenses.length.toString(),
          ),
        ),
        Expanded(child: Container()),
        Semantics(
          label: 'Last 7 days: ${recentExpensesTotal.toStringAsFixed(2)}€',
          child: _buildLabeledStat(
            icon: Icons.trending_up,
            value: recentExpensesTotal,
            label: localizations.get('last_7_days'),
            isCurrency: true,
            isPlaceholder: recentExpensesTotal == 0,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    if (group.expenses.isEmpty) return Container();

    return Column(
      children: [
        SizedBox(height: _sectionSpacing),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.get('recent_activity'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: _chartHeight,
                child: MiniExpenseChart(group: group, theme: theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: 'Add new expense',
        child: TextButton.icon(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AddNewExpensesGroupPage(trip: group), // Fix class name
              ),
            );
            if (result == true && context.mounted && onUpdated != null) {
              onUpdated!();
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            backgroundColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.05),
            padding: EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          icon: Icon(
            Icons.add,
            size: _iconSize,
            color: theme.colorScheme.onSurface,
          ),
          label: Text(
            localizations.get('add_expense').toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledStat({
    required IconData icon,
    required dynamic value,
    required String label,
    bool isCurrency = false,
    bool isPlaceholder = false,
  }) {
    final color = isPlaceholder
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : theme.colorScheme.onSurface;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: label.isEmpty
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: isCurrency
                  ? CurrencyDisplay(
                      value: value as double,
                      currency: '€',
                      valueFontSize: 16.0,
                      currencyFontSize: 12.0,
                      alignment: MainAxisAlignment.start,
                      showDecimals: true,
                      color: color,
                    )
                  : Text(
                      value.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPlaceholder
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
