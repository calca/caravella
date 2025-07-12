import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../data/expense_group.dart';
import '../../../data/expense_category.dart';
import '../../../data/expense_group_storage.dart';
import '../../../manager/expense/expense_form_component.dart';
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

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
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

  void _showAddExpenseSheet(BuildContext context, ExpenseGroup currentGroup) {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');

    // Salva il riferimento al notifier
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? group;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                        width: 28,
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
                        key: ValueKey(currentGroup.categories
                            .hashCode), // Forza rebuild quando le categorie cambiano
                        participants: currentGroup.participants
                            .map((p) => p.name)
                            .toList(),
                        categories:
                            currentGroup.categories.map((c) => c.name).toList(),
                        onExpenseAdded: (expense) async {
                          // Usa il notifier per aggiungere la spesa
                          await groupNotifier.addExpense(expense);
                          // Callback per aggiornare la UI della home
                          onExpenseAdded();
                          // Chiudi il modal
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        onCategoryAdded: (newCategory) async {
                          // Usa il notifier per aggiungere la categoria
                          await groupNotifier.addCategory(newCategory);
                          // La UI del form si aggiornerà automaticamente grazie al Consumer e alla ValueKey
                        },
                        shouldAutoClose: false,
                        // Passa la nuova categoria al form per la pre-selezione
                        newlyAddedCategory: groupNotifier.lastAddedCategory,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      // Pulisci il notifier quando il dialog si chiude
      notifier.clearCurrentGroup();
    });
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
            _buildTotalAmount(currentGroup),
            const SizedBox(height: _largSpacing),
            _buildStatistics(currentGroup),
            _buildRecentActivity(currentGroup),
            const Spacer(),
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
        if (currentGroup.pinned)
          Icon(
            Icons.push_pin,
            size: _iconSize,
            color: theme.colorScheme.onSurface,
          ),
      ],
    );
  }

  Widget _buildDateRange(ExpenseGroup currentGroup) {
    if (currentGroup.startDate == null && currentGroup.endDate == null) {
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
              _formatDateRange(currentGroup, localizations),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacing),
      ],
    );
  }

  Widget _buildTotalAmount(ExpenseGroup currentGroup) {
    final totalExpenses = currentGroup.expenses
        .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));

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

  Widget _buildStatistics(ExpenseGroup currentGroup) {
    final participantCount = currentGroup.participants.length;
    final recentExpensesTotal = currentGroup.expenses
        .where((e) =>
            e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));

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
          label: 'Expenses: ${currentGroup.expenses.length}',
          child: _buildCompactStat(
            icon: Icons.receipt_long_outlined,
            value: currentGroup.expenses.length.toString(),
          ),
        ),
        const Spacer(),
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

  Widget _buildRecentActivity(ExpenseGroup currentGroup) {
    if (currentGroup.expenses.isEmpty) return Container();

    return Column(
      children: [
        const SizedBox(height: _sectionSpacing),
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
                child: MiniExpenseChart(group: currentGroup, theme: theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, ExpenseGroup currentGroup) {
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: 'Add new expense',
        child: TextButton.icon(
          onPressed: () => _showAddExpenseSheet(context, currentGroup),
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

  Widget _buildCompactStat({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          size: _iconSize,
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledStat({
    required IconData icon,
    required double value,
    required String label,
    bool isCurrency = false,
    bool isPlaceholder = false,
  }) {
    final valueColor = isPlaceholder
        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
        : theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: _iconSize,
              color: valueColor,
            ),
            const SizedBox(width: 4),
            Text(
              isCurrency ? '${value.toStringAsFixed(2)}€' : value.toString(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
