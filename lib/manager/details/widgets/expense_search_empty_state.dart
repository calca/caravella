import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Empty state shown in [ExpenseSearchPage] when there are no results,
/// either because no search has been performed yet or filters excluded
/// everything.
class EmptySearchState extends StatelessWidget {
  final bool hasActiveFilters;

  const EmptySearchState({super.key, required this.hasActiveFilters});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilters
                  ? Icons.search_off_outlined
                  : Icons.search_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters ? gloc.search_no_results : gloc.search_expenses,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 8),
              Text(
                gloc.search_no_results_hint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
