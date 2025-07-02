import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../manager/add_new_expenses_group.dart';

class EmptyGroupsState extends StatelessWidget {
  final AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupAdded;

  const EmptyGroupsState({
    super.key,
    required this.localizations,
    required this.theme,
    required this.onGroupAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.get('no_active_groups'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            localizations.get('no_active_groups_subtitle'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddNewExpensesGroupPage(),
                ),
              );
              if (result == true) {
                onGroupAdded();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(localizations.get('create_first_group')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
