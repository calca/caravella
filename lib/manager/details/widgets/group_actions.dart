import 'package:flutter/material.dart';

class GroupActions extends StatelessWidget {
  final bool hasExpenses;
  final VoidCallback? onOverview;
  final VoidCallback? onOptions;
  const GroupActions({
    super.key,
    required this.hasExpenses,
    this.onOverview,
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
            message: hasExpenses ? 'Panoramica e statistiche' : 'Nessuna spesa',
            child: IconButton.filledTonal(
              onPressed: hasExpenses ? onOverview : null,
              icon: const Icon(Icons.dashboard_customize_outlined),
              iconSize: 24,
              tooltip: 'Panoramica',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainer,
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(54, 54),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Opzioni',
            child: IconButton.filledTonal(
              onPressed: onOptions,
              icon: const Icon(Icons.settings_outlined),
              iconSize: 24,
              tooltip: 'Opzioni',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainer,
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
