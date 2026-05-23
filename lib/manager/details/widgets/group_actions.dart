import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class GroupActions extends StatelessWidget {
  final bool hasExpenses;
  final VoidCallback? onOverview;
  final VoidCallback? onSearch;
  final VoidCallback? onOptions;
  const GroupActions({
    super.key,
    required this.hasExpenses,
    this.onOverview,
    this.onSearch,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final loc = MaterialLocalizations.of(context); // Removed unused local variable
    return SizedBox(
      height: 54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: hasExpenses
                ? gen.AppLocalizations.of(context).overview_and_statistics
                : gen.AppLocalizations.of(context).no_expenses_to_display,
            child: IconButton.filledTonal(
              onPressed: hasExpenses ? onOverview : null,
              icon: const Icon(Icons.analytics_outlined),
              iconSize: 24,
              tooltip: gen.AppLocalizations.of(context).overview,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLowest,
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(54, 54),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: hasExpenses
                ? gen.AppLocalizations.of(context).search_expenses
                : gen.AppLocalizations.of(context).no_expenses_to_display,
            child: IconButton.filledTonal(
              onPressed: hasExpenses ? onSearch : null,
              icon: const Icon(Icons.search_outlined),
              iconSize: 24,
              tooltip: gen.AppLocalizations.of(context).search_expenses,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLowest,
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(54, 54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
