import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// The "Shared" pill of a synced group (Home card, group page header). The
/// sync state itself is shown once, by Home's sync button next to the
/// settings gear. With [onTap] (group page) it is a button opening the
/// group's sync page, with a chevron to say so.
class GroupSyncBadge extends StatelessWidget {
  final ExpenseGroup group;

  /// Pill background and text color (they follow the surface it sits on).
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  const GroupSyncBadge({
    super.key,
    required this.group,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = Text(
      gen.AppLocalizations.of(context).sync_group_shared,
      style: theme.textTheme.labelSmall?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
    );
    final radius = BorderRadius.circular(16);
    if (onTap == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: background, borderRadius: radius),
        child: label,
      );
    }
    return Semantics(
      button: true,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                label,
                Icon(Icons.chevron_right_rounded, size: 16, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
