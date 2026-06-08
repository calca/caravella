import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';

/// Displays sync status indicators on a group card.
///
/// Shows two pieces of information:
/// 1. A **shared icon** (people) if the group has sync enabled.
/// 2. A **sync status dot** — green if fully synced, yellow/amber if there are
///    unsynced local changes.
///
/// When the group is not shared (`syncEnabled == false`), this widget renders
/// an empty [SizedBox].
class GroupSyncIndicator extends StatelessWidget {
  /// The expense group to show status for.
  final ExpenseGroup group;

  /// Whether this group's data is fully synced with peers.
  ///
  /// `true` → green dot, `false` → amber dot, `null` → no dot (unknown).
  final bool? isSynced;

  const GroupSyncIndicator({
    super.key,
    required this.group,
    this.isSynced,
  });

  @override
  Widget build(BuildContext context) {
    if (!group.syncEnabled) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final syncColor = _syncColor;

    return Semantics(
      label: _semanticsLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          if (isSynced != null) ...[
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: syncColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color get _syncColor => isSynced == true ? Colors.green : Colors.amber;

  String get _semanticsLabel {
    if (isSynced == null) return 'Shared group';
    return isSynced! ? 'Shared group, synced' : 'Shared group, not synced';
  }
}
