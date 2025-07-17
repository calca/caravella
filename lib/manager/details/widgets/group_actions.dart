import 'package:flutter/material.dart';

class GroupActions extends StatelessWidget {
  final bool hasExpenses;
  final VoidCallback? onOverview;
  final VoidCallback? onStatistics;
  final VoidCallback? onOptions;
  const GroupActions({
    super.key,
    required this.hasExpenses,
    this.onOverview,
    this.onStatistics,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = MaterialLocalizations.of(context);
    return SizedBox(
      height: 54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tooltip(
            message: hasExpenses ? 'Overview' : 'Nessuna spesa',
            child: IconButton.outlined(
              onPressed: hasExpenses ? onOverview : null,
              icon: const Icon(Icons.dashboard_customize_rounded),
              iconSize: 24,
              tooltip: 'Overview',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLowest,
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(54, 54),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: hasExpenses ? 'Statistiche' : 'Nessuna spesa',
            child: IconButton.outlined(
              onPressed: hasExpenses ? onStatistics : null,
              icon: const Icon(Icons.analytics_rounded),
              iconSize: 24,
              tooltip: 'Statistiche',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLowest,
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(54, 54),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Opzioni',
            child: IconButton.outlined(
              onPressed: onOptions,
              icon: const Icon(Icons.settings_rounded),
              iconSize: 24,
              tooltip: 'Opzioni',
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
