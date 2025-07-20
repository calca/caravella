import 'package:flutter/material.dart';
import '../../../../data/expense_group.dart';
import '../../../../app_localizations.dart';
import '../../../../widgets/currency_display.dart';

class GeneralStats extends StatelessWidget {
  final ExpenseGroup trip;
  final AppLocalizations loc;

  const GeneralStats({
    super.key,
    required this.trip,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        trip.expenses.fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
    final averageAmount =
        trip.expenses.isNotEmpty ? totalAmount / trip.expenses.length : 0.0;
    final maxExpense = trip.expenses.isNotEmpty
        ? trip.expenses
            .where((e) => e.amount != null)
            .reduce((a, b) => (a.amount ?? 0) > (b.amount ?? 0) ? a : b)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('general_statistics'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        // Spesa media
        _buildFlatStatItem(
          context,
          loc.get('average_expense'),
          CurrencyDisplay(
            value: averageAmount,
            currency: trip.currency,
            valueFontSize: 18,
            currencyFontSize: 14,
            showDecimals: true,
          ),
        ),

        if (maxExpense != null) ...[
          // Spesa più alta
          _buildFlatStatItem(
            context,
            'Maggiore spesa: ${maxExpense.category.toString().isNotEmpty ? maxExpense.category : loc.get('uncategorized')}',
            CurrencyDisplay(
              value: maxExpense.amount ?? 0,
              currency: trip.currency,
              valueFontSize: 18,
              currencyFontSize: 14,
              showDecimals: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFlatStatItem(
      BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          content,
        ],
      ),
    );
  }
}
