import 'package:flutter/material.dart';

class NoExpense extends StatelessWidget {
  final String semanticLabel;
  final String noExpenseLabel;
  final String addFirstExpenseLabel;

  const NoExpense({
    super.key,
    required this.semanticLabel,
    required this.noExpenseLabel,
    required this.addFirstExpenseLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            semanticLabel: semanticLabel,
          ),
          const SizedBox(height: 16),
          Text(
            noExpenseLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            addFirstExpenseLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
