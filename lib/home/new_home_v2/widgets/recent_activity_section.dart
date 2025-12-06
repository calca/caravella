import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:intl/intl.dart';

/// Section displaying recent activity/expenses.
class RecentActivitySection extends StatelessWidget {
  final List<ExpenseDetails> expenses;

  const RecentActivitySection({
    super.key,
    required this.expenses,
  });

  IconData _getCategoryIcon(ExpenseCategory category) {
    // Simple category to icon mapping
    final categoryName = category.name.toLowerCase();
    if (categoryName.contains('food') || categoryName.contains('cibo')) {
      return Icons.restaurant;
    } else if (categoryName.contains('transport')) {
      return Icons.directions_car;
    } else if (categoryName.contains('cinema') || categoryName.contains('movie')) {
      return Icons.movie;
    } else if (categoryName.contains('shopping')) {
      return Icons.shopping_cart;
    }
    return Icons.payment;
  }

  Color _getCategoryColor(ExpenseCategory category) {
    // Simple category to color mapping
    final categoryName = category.name.toLowerCase();
    if (categoryName.contains('food') || categoryName.contains('cibo')) {
      return const Color(0xFFFF9800);
    } else if (categoryName.contains('transport')) {
      return const Color(0xFF2196F3);
    } else if (categoryName.contains('cinema') || categoryName.contains('movie')) {
      return const Color(0xFF4ECDC4);
    } else if (categoryName.contains('shopping')) {
      return const Color(0xFF9C27B0);
    }
    return const Color(0xFF4ECDC4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Attività Recente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            final category = expense.category;
            final icon = _getCategoryIcon(category);
            final color = _getCategoryColor(category);

            // Determine payment status text
            String statusText = 'Hai pagato tu';
            if (expense.paidBy.name != 'Tu') {
              statusText = 'Ha pagato ${expense.paidBy.name}';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Amount
                  Text(
                    '${expense.amount.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
