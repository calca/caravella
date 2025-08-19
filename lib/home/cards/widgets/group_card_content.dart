import 'weekly_expense_chart.dart';
import 'monthly_expense_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_localizations.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../data/expense_group.dart';
import '../../../manager/expense/expense_form_component.dart';
import '../../../widgets/currency_display.dart';

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

  void _showAddExpenseSheet(BuildContext context, ExpenseGroup currentGroup) {
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                      const SizedBox(height: 12),
                      // Removed title text per UX request (icon-only header)
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
                        top: 0,
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom +
                            MediaQuery.of(context).padding.bottom +
                            20,
                      ),
                      child: ExpenseFormComponent(
                        participants: currentGroup.participants,
                        categories: currentGroup.categories,
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
                          // La UI del form si aggiornerà automaticamente grazie al Consumer e didUpdateWidget
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
            _buildTotalAmount(currentGroup),
            // Numero partecipanti subito sotto al totale
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Semantics(
                    label: 'Participants: ${currentGroup.participants.length}',
                    child: _buildCompactStat(
                      icon: Icons.people_outline,
                      value: currentGroup.participants.length.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _largSpacing),
            _buildRecentActivity(currentGroup),
            const Spacer(),
            _buildStatistics(currentGroup),
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
        if (currentGroup.pinned)
          Icon(
            Icons.push_pin_outlined,
            size: _iconSize,
            color: theme.colorScheme.onSurface,
          ),
      ],
    );
  }

  Widget _buildDateRange(ExpenseGroup currentGroup) {
    if (currentGroup.startDate == null && currentGroup.endDate == null) {
      return const SizedBox(height: _spacing);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _spacing),
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
    final totalExpenses = currentGroup.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );

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
    final now = DateTime.now();
    // Calcola il lunedì della settimana corrente
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Genera i 7 giorni da lunedì a domenica
    final dailyTotals = List<double>.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return currentGroup.expenses
          .where(
            (e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day,
          )
          .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    });
    // weeklyTotal non più usato

    // Spesa per ogni giorno del mese corrente
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final dailyMonthTotals = List<double>.generate(daysInMonth, (i) {
      final day = startOfMonth.add(Duration(days: i));
      return currentGroup.expenses
          .where(
            (e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day,
          )
          .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    });
    // monthlyTotal non più usato

    // Statistiche base
    return Column(
      children: [
        // Settimana
        WeeklyExpenseChart(dailyTotals: dailyTotals, theme: theme),
        const SizedBox(height: 12),
        // Mese
        MonthlyExpenseChart(dailyTotals: dailyMonthTotals, theme: theme),
      ],
    );

    // Dead code removed, now handled in the new Column above
  }

  Widget _buildRecentActivity(ExpenseGroup currentGroup) {
    // Recent activity and chart removed for cleaner UI
    return Container();
  }

  Widget _buildAddButton(BuildContext context, ExpenseGroup currentGroup) {
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: 'Add expense',
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

  Widget _buildCompactStat({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: _iconSize, color: theme.colorScheme.onSurface),
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
}
