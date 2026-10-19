import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../manager/group/pages/expense_group_sync_page.dart';
import 'sync_activity.dart';

/// The "Shared" pill of a synced group, with its sync state: a small
/// spinner while syncing, a check once synced, a warning (tap to open the
/// group's sync page) after a failure.
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
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    SyncActivity? activity;
    try {
      activity = context.watch<SyncActivity>();
    } on ProviderNotFoundException {
      activity = null;
    }
    final state = activity?.stateOf(group.id) ?? GroupSyncState.idle;

    final Widget? leading = switch (state) {
      GroupSyncState.syncing => SizedBox.square(
        dimension: 10,
        child: CircularProgressIndicator(strokeWidth: 1.6, color: foreground),
      ),
      GroupSyncState.synced => Icon(
        Icons.check_rounded,
        size: 13,
        color: s.success,
      ),
      GroupSyncState.error => Icon(
        Icons.error_outline_rounded,
        size: 13,
        color: s.warning,
      ),
      GroupSyncState.idle => null,
    };
    final stateLabel = switch (state) {
      GroupSyncState.syncing => gloc.sync_state_syncing,
      GroupSyncState.synced => gloc.sync_state_synced,
      GroupSyncState.error => gloc.sync_state_error,
      GroupSyncState.idle => null,
    };

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 4)],
          Text(
            gloc.sync_group_shared,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final label = stateLabel == null
        ? gloc.sync_group_shared
        : '${gloc.sync_group_shared}, $stateLabel';
    if (state != GroupSyncState.error) {
      return Semantics(label: label, excludeSemantics: true, child: pill);
    }
    void open() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseGroupSyncPage(trip: group)),
    );
    return Semantics(
      label: label,
      button: true,
      onTap: open,
      excludeSemantics: true,
      child: GestureDetector(onTap: open, child: pill),
    );
  }
}
