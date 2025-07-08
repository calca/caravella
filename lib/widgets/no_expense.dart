import 'package:flutter/material.dart';

class NoExpense extends StatelessWidget {
  final String semanticLabel;
  const NoExpense({super.key, required this.semanticLabel});

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
            'Nessuna spesa',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi la prima spesa per iniziare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
