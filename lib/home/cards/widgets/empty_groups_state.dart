import 'package:material_ui/material_ui.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../navigation_helpers.dart';
import '../../../manager/history/expenses_history_page.dart';

/// Home with no active group (all archived): a card with an icon, a title,
/// the reason, and wide buttons to create a group or see all of them.
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
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(24);
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: const StadiumBorder(),
      elevation: 0,
    );

    return Center(
      child: SingleChildScrollView(
        child: CardOutline(
          borderRadius: radius,
          child: Material(
            color: s.raisedSurface,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.onSurface.withValues(alpha: 0.06),
                      ),
                      child: Icon(
                        allArchived
                            ? Icons.inventory_2_outlined
                            : Icons.group_add_outlined,
                        size: 30,
                        color: s.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.no_active_groups,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (allArchived) ...[
                    const SizedBox(height: 6),
                    Text(
                      localizations.all_groups_archived_info,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      final groupId = await NavigationHelpers.openGroupCreation(
                        context,
                      );
                      if (groupId != null) onGroupAdded();
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(localizations.create_first_group),
                    style: buttonStyle,
                  ),
                  if (allArchived) ...[
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExpesensHistoryPage(),
                        ),
                      ),
                      icon: const Icon(Icons.folder_copy_outlined),
                      label: Text(localizations.view_all_groups),
                      style: buttonStyle,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
