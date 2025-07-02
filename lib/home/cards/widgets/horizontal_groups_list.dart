import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import 'group_card.dart';

class HorizontalGroupsList extends StatelessWidget {
  final List<ExpenseGroup> groups;
  final AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;

  const HorizontalGroupsList({
    super.key,
    required this.groups,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: groups.length,
      padEnds: false,
      controller: PageController(
        viewportFraction: 0.85, // Mostra parte della card successiva
      ),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GroupCard(
            group: group,
            localizations: localizations,
            theme: theme,
            onGroupUpdated: onGroupUpdated,
          ),
        );
      },
    );
  }
}
