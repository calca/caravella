import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// The "Shared" pill of a synced group (Home card, group page header). The
/// sync state itself is shown once, by Home's sync button next to the
/// settings gear.
class GroupSyncBadge extends StatelessWidget {
  final ExpenseGroup group;

  /// Pill background and text color (they follow the surface it sits on).
  final Color background;
  final Color foreground;

  const GroupSyncBadge({
    super.key,
    required this.group,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        gen.AppLocalizations.of(context).sync_group_shared,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
