import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import '../../../data/expense_category.dart';
import '../../../data/expense_group_storage.dart';
import '../../../manager/expense/expense_form_component.dart';
import '../../../widgets/currency_display.dart';
import 'mini_expense_chart.dart';

class GroupCardContent extends StatelessWidget {
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

  void _showAddExpenseSheet(BuildContext context) {
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
                    group.title,
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
                        Navigator.pop(context);
                      }
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

  @override
  Widget build(BuildContext context) {
    final totalExpenses = group.expenses
        .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    final participantCount = group.participants.length;
    final recentExpensesTotal = group.expenses
        .where((e) =>
            e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con titolo e pin prominente
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                group.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (group.pinned)
              Icon(
                Icons.push_pin,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Date range (if available)
        if (group.startDate != null || group.endDate != null)
          Text(
            _formatDateRange(group, localizations),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        
        if (group.startDate != null || group.endDate != null)
          const SizedBox(height: 8),

        // Total expenses - full width aligned right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CurrencyDisplay(
              value: totalExpenses,
              currency: '€',
              valueFontSize: 52.0,
              currencyFontSize: 32.0,
              alignment: MainAxisAlignment.end,
              showDecimals: true,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Statistiche con etichette più chiare (layout a griglia)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Participants - compact
            _buildCompactStat(
              icon: Icons.people_outline,
              value: participantCount.toString(),
            ),
            const SizedBox(width: 16),
            // Expenses - compact
            _buildCompactStat(
              icon: Icons.receipt_long_outlined,
              value: group.expenses.length.toString(),
            ),
            // Spacer to push last 7 days to the right
            Expanded(child: Container()),
            // Last 7 days - right aligned (mantiene sempre lo spazio nel layout)
            recentExpensesTotal > 0
                ? _buildLabeledStat(
                    icon: Icons.trending_up,
                    value: recentExpensesTotal,
                    label: localizations.get('last_7_days'),
                    isCurrency: true,
                  )
                : SizedBox(
                    width: 80, // Larghezza fissa per mantenere lo spazio
                    height: 60, // Altezza fissa per mantenere l'allineamento
                    child: Container(), // Contenitore vuoto ma con dimensioni
                  ),
          ],
        ),

        // Mostra la sezione attività recenti solo se ci sono spese
        if (group.expenses.isNotEmpty) ...[
          const SizedBox(height: 28),
          
          // Grafico con più spazio respirabile
          Column(
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
                height: 60, // Aumentato per il nuovo grafico
                child: MiniExpenseChart(group: group, theme: theme),
              ),
            ],
          ),
        ],

        // Spacer per spingere il bottone sempre in fondo
        const Spacer(),

        // Bottone "Aggiungi" sempre in fondo alla card
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showAddExpenseSheet(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              backgroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.add,
              size: 20,
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
      ],
    );
  }

  Widget _buildLabeledStat({
    required IconData icon,
    required dynamic value,
    required String label,
    bool isCurrency = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: label.isEmpty ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurface,
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
                      color: theme.colorScheme.onSurface,
                    )
                  : Text(
                      value.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
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
              color: theme.colorScheme.onSurfaceVariant,
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
