import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../models/sync_event.dart';

/// Widget to display sync status for a group
class SyncStatusIndicator extends StatelessWidget {
  final GroupSyncState? syncState;
  final bool compact;

  const SyncStatusIndicator({
    super.key,
    required this.syncState,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (syncState == null || syncState!.status == SyncStatus.disabled) {
      return const SizedBox.shrink();
    }

    final status = syncState!.status;
    final color = _getStatusColor(status, theme);
    final icon = _getStatusIcon(status);
    final text = _getStatusText(status, gloc);

    if (compact) {
      return Tooltip(
        message: text,
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.synced:
        return theme.colorScheme.primary;
      case SyncStatus.syncing:
        return theme.colorScheme.tertiary;
      case SyncStatus.error:
        return theme.colorScheme.error;
      case SyncStatus.disabled:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.syncing:
        return Icons.cloud_sync;
      case SyncStatus.error:
        return Icons.cloud_off;
      case SyncStatus.disabled:
        return Icons.cloud_off;
    }
  }

  String _getStatusText(SyncStatus status, gen.AppLocalizations gloc) {
    switch (status) {
      case SyncStatus.synced:
        return gloc.synced ?? 'Synced';
      case SyncStatus.syncing:
        return gloc.syncing ?? 'Syncing...';
      case SyncStatus.error:
        return gloc.sync_error ?? 'Sync error';
      case SyncStatus.disabled:
        return gloc.sync_disabled ?? 'Sync disabled';
    }
  }
}
