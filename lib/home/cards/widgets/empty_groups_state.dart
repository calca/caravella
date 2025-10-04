import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/group/pages/expenses_group_edit_page.dart';
import '../../../manager/group/group_edit_mode.dart';

class EmptyGroupsState extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupAdded;
  final bool allArchived;

  const EmptyGroupsState({
    super.key,
    required this.localizations,
    required this.theme,
    required this.onGroupAdded,
    this.allArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Render the welcome logo in greyscale with muted opacity
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/home/welcome/welcome-logo.png',
                height: 80,
                fit: BoxFit.contain,
                semanticLabel: localizations.welcome_logo_semantic,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.no_active_groups,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            localizations.no_active_groups_subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (allArchived) ...[
            const SizedBox(height: 12),
            Text(
              localizations.all_groups_archived_info,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const ExpensesGroupEditPage(mode: GroupEditMode.create),
                ),
              );
              if (result == true) {
                onGroupAdded();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(localizations.create_first_group),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
