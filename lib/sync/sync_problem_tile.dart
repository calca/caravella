import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// Names for what a [SyncProblem] refers to by id: paired devices and
/// groups, read once for a page.
class SyncNames {
  final Map<String, String> devices;
  final Map<String, String> groups;

  const SyncNames({this.devices = const {}, this.groups = const {}});

  /// The names of the paired devices and of the [groupIds] groups.
  static Future<SyncNames> load(
    SyncOrchestrator orchestrator,
    Iterable<String> groupIds,
  ) async {
    final devices = <String, String>{};
    try {
      for (final d in await orchestrator.getPairedDevices()) {
        devices[d.deviceId] = d.deviceName;
      }
    } catch (e) {
      LoggerService.warning('Paired devices unavailable: $e', name: 'sync');
    }
    final groups = <String, String>{};
    for (final id in groupIds.toSet()) {
      final group = await ExpenseGroupStorageV2.getTripById(id);
      if (group != null) groups[id] = group.title;
    }
    return SyncNames(devices: devices, groups: groups);
  }

  /// The device's name: as paired, else as it said, else "Google Drive" for
  /// the cloud, else "Unknown device".
  String device(
    gen.AppLocalizations loc,
    String channel,
    String peerId, [
    String? said,
  ]) {
    if (channel == 'cloud') return 'Google Drive';
    final name = devices[peerId] ?? said;
    if (name != null && name.isNotEmpty) return name;
    return loc.sync_unknown_device;
  }

  /// The problem's subject: "Group · Device", or the device alone.
  String subject(gen.AppLocalizations loc, SyncProblem p) {
    final device = this.device(loc, p.channel, p.peerId, p.peerName);
    final group = p.groupId == null ? null : groups[p.groupId];
    return group == null ? device : '$group · $device';
  }
}

/// What went wrong, and what to do about it, in a sentence.
String syncProblemText(gen.AppLocalizations loc, SyncProblem p, String device) {
  return switch (p.reason) {
    SyncProblemReason.notShared => loc.sync_problem_not_shared(device),
    SyncProblemReason.unreadable => loc.sync_problem_unreadable,
    SyncProblemReason.notPaired => loc.sync_problem_not_paired,
    SyncProblemReason.peerError => loc.sync_problem_peer_error,
    SyncProblemReason.cloudUnreachable => loc.sync_problem_cloud,
    SyncProblemReason.failed => loc.sync_problem_failed,
  };
}

/// "<1 min", "5 min", "2h", "3d" since [time].
String syncAgo(DateTime time) {
  final diff = DateTime.now().toUtc().difference(time.toUtc());
  if (diff.inSeconds < 60) return '<1 min';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

/// One row of Settings → Sync's "To fix": an ochre warning, which group and
/// device, why and what to do, and how long ago.
class SyncProblemTile extends StatelessWidget {
  final SyncProblem problem;
  final SyncNames names;
  final VoidCallback? onTap;

  const SyncProblemTile({
    super.key,
    required this.problem,
    required this.names,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final device = names.device(
      loc,
      problem.channel,
      problem.peerId,
      problem.peerName,
    );
    final subject = names.subject(loc, problem);
    final text = syncProblemText(loc, problem, device);
    final ago = syncAgo(problem.at);
    return Semantics(
      button: onTap != null,
      label: '$subject. $text. $ago',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.warning.withValues(alpha: 0.16),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: s.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ago,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: s.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
