import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
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

    return EmptyStateView(
      icon: hasActiveFilters
          ? Icons.search_off_outlined
          : Icons.search_outlined,
      message: hasActiveFilters ? gloc.search_no_results : gloc.search_expenses,
      hint: hasActiveFilters ? gloc.search_no_results_hint : null,
    );
  }
}
