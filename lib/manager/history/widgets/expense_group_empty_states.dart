import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../group/pages/expenses_group_edit_page.dart';

class ExpsenseGroupEmptyStates extends StatelessWidget {
  final String searchQuery;
  final String periodFilter;
  final VoidCallback onTripAdded;

  const ExpsenseGroupEmptyStates({
    super.key,
    required this.searchQuery,
    required this.periodFilter,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchEmptyState(context);
    } else if (periodFilter != 'all') {
      return _buildNoResultsState(context);
    } else {
      return _buildNoTripsState(context);
    }
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          gen.AppLocalizations.of(context).no_results_found,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          gen.AppLocalizations.of(context).try_adjust_filter_or_search,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 64,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          '${gen.AppLocalizations.of(context).no_search_results} "$searchQuery"',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          gen.AppLocalizations.of(context).try_different_search,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNoTripsState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.luggage,
          size: 100,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          gen.AppLocalizations.of(context).no_trips_found,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(gen.AppLocalizations.of(context).add_trip),
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExpensesGroupEditPage(),
              ),
            );
            if (result == true) {
              onTripAdded();
            }
          },
        ),
      ],
    );
  }
}
