import 'package:flutter/material.dart';
import '../../../data/expense_details.dart';
import 'expense_amount_card.dart';

class ExpenseList extends StatelessWidget {
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;
  const ExpenseList({
    super.key,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }
    final sorted = List<ExpenseDetails>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return Column(
      children: [
        ...sorted.map((expense) => Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ExpenseAmountCard(
                title: expense.category.name,
                coins: (expense.amount ?? 0).toInt(),
                checked: true,
                paidBy: expense.paidBy,
                category: null,
                date: expense.date,
                currency: currency,
                onTap: () => onExpenseTap(expense),
              ),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
