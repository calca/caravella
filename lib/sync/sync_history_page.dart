import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Full-page sync history, listing the last sync events from
/// [SyncOrchestrator.getHistory].
///
/// Reached from Settings → Sync (all groups, [groupId] left `null`) and from
/// a single group's sync page (scoped to [groupId]/[groupTitle], reusing the
/// same page and entry rendering rather than a separate view).
class SyncHistoryPage extends StatelessWidget {
  final SyncOrchestrator orchestrator;

  /// When set, only events that touched this group are shown.
  final String? groupId;

  /// Title of the group [groupId] belongs to, used in the page description.
  final String? groupTitle;

  const SyncHistoryPage({
    super.key,
    required this.orchestrator,
    this.groupId,
    this.groupTitle,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppSystemUI.surface(
      child: Scaffold(
        appBar: const CaravellaAppBar(),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            SettingsSection(
              title: loc.sync_history_title,
              description: groupId != null
                  ? loc.sync_history_group_desc(groupTitle ?? '')
                  : '',
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: orchestrator.getHistory(limit: 20, groupId: groupId),
                  builder: (context, snapshot) {
                    final history = snapshot.data ?? [];

                    if (history.isEmpty) {
                      return _buildEmptyState(context, loc);
                    }

                    return SettingsCard(
                      context: context,
                      color: colorScheme.surface,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: history
                            .map((e) => _buildEntry(context, loc, e))
                            .toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          loc.sync_history_empty,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildEntry(
    BuildContext context,
    gen.AppLocalizations loc,
    Map<String, dynamic> entry,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final channel = entry['channel'] as String? ?? '';
    final peerId = entry['peerId'] as String? ?? '';
    final applied = entry['applied'] as int? ?? 0;
    final skipped = entry['skipped'] as int? ?? 0;
    final errors = entry['errors'] as int? ?? 0;
    final timestamp = entry['timestamp'] as String? ?? '';

    final channelDisplay = _channelInfo(channel, loc);
    final relativeTime = _relativeTimestamp(timestamp);
    final sent = skipped;
    final received = applied;

    return Semantics(
      label:
          '${channelDisplay.$2}, $peerId, $relativeTime, $received received, $sent sent',
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Text(channelDisplay.$1, style: const TextStyle(fontSize: 20)),
        title: Text(
          peerId.isNotEmpty ? peerId : channelDisplay.$2,
          style: textTheme.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          loc.sync_records_exchanged(sent, received),
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              relativeTime,
              style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
            ),
            if (errors > 0)
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: colorScheme.error),
          ],
        ),
      ),
    );
  }

  /// Returns (emoji, display name) for a sync channel.
  (String, String) _channelInfo(String channel, gen.AppLocalizations loc) {
    return switch (channel) {
      'lan' => ('📡', loc.sync_channel_lan),
      'nearby' || 'bluetooth' => ('🔵', loc.sync_channel_bluetooth),
      'cloud' => ('☁️', loc.sync_channel_cloud),
      _ => ('🔄', channel),
    };
  }

  String _relativeTimestamp(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inSeconds < 60) return '<1 min';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return '';
    }
  }
}
