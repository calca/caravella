import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../group/add_new_expenses_group.dart';

class ExpsenseGroupEmptyStates extends StatelessWidget {
  final String searchQuery;
  final String periodFilter;
  final AppLocalizations localizations;
  final VoidCallback onTripAdded;

  const ExpsenseGroupEmptyStates({
    super.key,
    required this.searchQuery,
    required this.periodFilter,
    required this.localizations,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchEmptyState(context);
    } else if (periodFilter == 'all') {
      return _buildNoTripsState(context);
    } else {
      return const SizedBox.shrink();
    }
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
          '${localizations.get('no_search_results')} "$searchQuery"',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.get('try_different_search'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
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
          localizations.get('no_trips_found'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(localizations.get('add_trip')),
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddNewExpensesGroupPage(),
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
