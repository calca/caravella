import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'sync_problem_tile.dart';

/// Full-page sync history, listing the last sync events from
/// [SyncOrchestrator.getHistory]: the device by name (as paired), the
/// channel and what was exchanged, and under it what went wrong, with the
/// group it was about.
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

    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.sync_title,
        title: loc.sync_history_title,
        description: groupId != null
            ? loc.sync_history_group_desc(groupTitle ?? '')
            : null,
        children: [
          FutureBuilder<(List<Map<String, dynamic>>, SyncNames)>(
            future: _load(),
            builder: (context, snapshot) {
              final (history, names) =
                  snapshot.data ??
                  (const <Map<String, dynamic>>[], const SyncNames());
              if (history.isEmpty) return _buildEmptyState(context, loc);
              return SettingsGroup(
                children: [
                  for (final e in history) _buildEntry(context, loc, e, names),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<(List<Map<String, dynamic>>, SyncNames)> _load() async {
    final history = await orchestrator.getHistory(limit: 20, groupId: groupId);
    final names = await SyncNames.load(orchestrator, [
      for (final e in history)
        for (final p in _problems(e))
          if (p.groupId != null) p.groupId!,
    ]);
    return (history, names);
  }

  static List<SyncProblem> _problems(Map<String, dynamic> entry) =>
      (entry['problems'] as List?)?.whereType<SyncProblem>().toList() ??
      const [];

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
    SyncNames names,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final channel = entry['channel'] as String? ?? '';
    final peerId = entry['peerId'] as String? ?? '';
    final applied = entry['applied'] as int? ?? 0;
    final skipped = entry['skipped'] as int? ?? 0;
    final failed = entry['failed'] as bool? ?? false;
    final timestamp = entry['timestamp'] as String? ?? '';
    final problems = _problems(entry);

    final channelDisplay = _channelInfo(channel, loc);
    final relativeTime = _relativeTimestamp(timestamp);
    final sent = skipped;
    final received = applied;
    final device = peerId.isEmpty && channel != 'cloud'
        ? channelDisplay.$2
        : names.device(loc, channel, peerId, entry['peerName'] as String?);
    final summary =
        '${channelDisplay.$2} · '
        '${failed ? loc.sync_history_failed : loc.sync_records_exchanged(sent, received)}';
    // "Group: why", or just why for the whole exchange.
    final lines = [
      for (final p in problems)
        [
          if (p.groupId != null && names.groups[p.groupId] != null)
            names.groups[p.groupId]!,
          syncProblemText(loc, p, device),
        ].join(': '),
    ];

    return Semantics(
      label: [device, summary, ...lines, relativeTime].join('. '),
      excludeSemantics: true,
      child: SettingsTile(
        icon: channelDisplay.$1,
        title: device,
        subtitleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1, right: 6),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: colorScheme.warning,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Text(
          relativeTime,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Returns (icon, display name) for a sync channel.
  (IconData, String) _channelInfo(String channel, gen.AppLocalizations loc) {
    return switch (channel) {
      'lan' => (Icons.wifi, loc.sync_channel_lan),
      'nearby' || 'bluetooth' => (Icons.bluetooth, loc.sync_channel_bluetooth),
      'cloud' => (Icons.cloud_outlined, loc.sync_channel_cloud),
      _ => (Icons.sync, channel),
    };
  }

  String _relativeTimestamp(String iso) {
    if (iso.isEmpty) return '';
    try {
      return syncAgo(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }
}
