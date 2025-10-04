import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

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
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            semanticLabel: semanticLabel,
          ),
          const SizedBox(height: 16),
          Text(
            gen.AppLocalizations.of(context).no_expense_label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gen.AppLocalizations.of(context).add_first_expense,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
