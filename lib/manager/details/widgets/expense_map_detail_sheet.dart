import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_details.dart';
import '../../../widgets/bottom_sheet_scaffold.dart';
import 'expense_amount_card.dart';

/// Bottom sheet that displays expense details when clicking on a map marker
class ExpenseMapDetailSheet extends StatelessWidget {
  final List<ExpenseDetails> expenses;
  final String currency;

  const ExpenseMapDetailSheet({
    super.key,
    required this.expenses,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final firstExpense = expenses.first;
    final locationName = firstExpense.location?.name ??
        firstExpense.location?.address ??
        '${firstExpense.location?.latitude?.toStringAsFixed(6)}, ${firstExpense.location?.longitude?.toStringAsFixed(6)}';

    return GroupBottomSheetScaffold(
      title: locationName,
      scrollable: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location count badge
          if (expenses.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  gloc.expense_count(expenses.length),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // List of expenses at this location
          ...expenses.map((expense) {
            return ExpenseAmountCard(
              title: expense.name ?? expense.category.name,
              coins: (expense.amount ?? 0).toInt(),
              checked: false,
              paidBy: expense.paidBy,
              category: expense.category.name,
              date: expense.date,
              currency: currency,
            );
          }),
        ],
      ),
    );
  }
}
