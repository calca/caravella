import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../sync_problem_tile.dart';
import 'paired_device_sheet.dart';

/// The paired devices, each with how its sync is doing (a dot in the same
/// language as the groups' "Shared" pill, and a line: updated how long ago,
/// never, or the last exchange failed). Tapping one opens
/// [showPairedDeviceSheet] to update it now, or take it off.
///
/// With [groupId], the devices granted that group (its sync page; taking
/// one off revokes only that group). Without, every paired device with the
/// groups it shares (Settings › Sync with others; there it's forgotten).
///
/// Self-loads via [orchestrator] on mount, and again on each sync event
/// (a device paired, an exchange finished).
class PairedDevicesList extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  /// The group whose devices this lists, or null for every paired device.
  final String? groupId;

  /// The group's title, for "Take off «…»" in the sheet.
  final String? groupTitle;

  /// Shown when there are no devices; nothing at all when null.
  final String? emptyText;

  /// Built instead of [emptyText] when there are no devices.
  final WidgetBuilder? emptyBuilder;

  /// A last row after the devices (e.g. "Invite another device"), only
  /// when there is at least one.
  final Widget? trailing;

  /// Called with the number of devices each time the list loads.
  final ValueChanged<int>? onLoaded;

  const PairedDevicesList({
    super.key,
    required this.orchestrator,
    this.groupId,
    this.groupTitle,
    this.emptyText,
    this.emptyBuilder,
    this.trailing,
    this.onLoaded,
  });

  @override
  State<PairedDevicesList> createState() => _PairedDevicesListState();
}

class _Entry {
  final PairedDevice device;
  final DeviceSyncInfo info;
  const _Entry(this.device, this.info);
}

class _PairedDevicesListState extends State<PairedDevicesList> {
  List<_Entry>? _entries;
  SyncNames _names = const SyncNames();
  StreamSubscription<SyncEvent>? _events;

  @override
  void initState() {
    super.initState();
    _load();
    _events = widget.orchestrator.events.listen((event) {
      if (event is PeerPaired ||
          event is SyncCompleted ||
          event is SyncFailed) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final groupId = widget.groupId;
    final devices = groupId == null
        ? await widget.orchestrator.getPairedDevices()
        : await widget.orchestrator.getPairedDevicesForGroup(groupId);
    final entries = [
      for (final d in devices)
        _Entry(d, await widget.orchestrator.getDeviceSyncInfo(d.deviceId)),
    ];
    final names = await SyncNames.load(
      widget.orchestrator,
      entries.expand((e) => e.info.groupIds),
    );
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _names = names;
    });
    widget.onLoaded?.call(entries.length);
  }

  Future<void> _open(_Entry entry) async {
    await showPairedDeviceSheet(
      context,
      orchestrator: widget.orchestrator,
      device: entry.device,
      info: entry.info,
      groupTitles: [for (final id in entry.info.groupIds) ?_names.groups[id]],
      groupId: widget.groupId,
      groupTitle: widget.groupTitle,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final entries = _entries;
    if (entries == null) return const SizedBox.shrink();

    if (entries.isEmpty) {
      final builder = widget.emptyBuilder;
      if (builder != null) return builder(context);
      final empty = widget.emptyText;
      if (empty == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          empty,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final (i, e) in entries.indexed) ...[
          if (i > 0) const Divider(height: 1),
          _DeviceRow(
            device: e.device,
            info: e.info,
            groups: widget.groupId == null
                ? [for (final id in e.info.groupIds) ?_names.groups[id]]
                : null,
            onTap: () => _open(e),
            loc: loc,
          ),
        ],
        if (widget.trailing case final trailing?) ...[
          const Divider(height: 1),
          trailing,
        ],
      ],
    );
  }
}

/// How sync with a device is doing, for its dot and its line.
enum DeviceSyncHealth { ok, failed, never }

DeviceSyncHealth deviceSyncHealth(DeviceSyncInfo info) => info.lastFailed
    ? DeviceSyncHealth.failed
    : info.lastSyncAt == null
    ? DeviceSyncHealth.never
    : DeviceSyncHealth.ok;

/// "Updated 2h ago", "Never updated · paired 7 Nov", "Last exchange didn't
/// go through".
String deviceSyncLine(
  BuildContext context,
  gen.AppLocalizations loc,
  PairedDevice device,
  DeviceSyncInfo info,
) {
  final at = info.lastSyncAt;
  switch (deviceSyncHealth(info)) {
    case DeviceSyncHealth.failed:
      return loc.sync_device_failed;
    case DeviceSyncHealth.never:
      final date = DateFormat.MMMd(
        Localizations.localeOf(context).toString(),
      ).format(device.pairedAt.toLocal());
      return loc.sync_device_never(date);
    case DeviceSyncHealth.ok:
      final diff = DateTime.now().toUtc().difference(at!.toUtc());
      return diff.inSeconds < 60
          ? loc.sync_device_synced_now
          : loc.sync_device_synced_ago(syncAgo(at));
  }
}

/// The dot before the line: filled green, filled ochre, or hollow.
class DeviceSyncDot extends StatelessWidget {
  final DeviceSyncHealth health;

  const DeviceSyncDot({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: switch (health) {
        DeviceSyncHealth.ok => BoxDecoration(
          shape: BoxShape.circle,
          color: s.success,
        ),
        DeviceSyncHealth.failed => BoxDecoration(
          shape: BoxShape.circle,
          color: s.warning,
        ),
        DeviceSyncHealth.never => BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: s.onSurfaceVariant.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
      },
    );
  }
}

/// The device's platform icon in a neutral circle.
class DeviceAvatar extends StatelessWidget {
  final String platform;
  final double size;

  const DeviceAvatar({super.key, required this.platform, this.size = 40});

  static IconData iconFor(String platform) => switch (platform) {
    'ios' || 'android' => Icons.smartphone,
    'macos' || 'windows' || 'linux' => Icons.laptop,
    _ => Icons.devices_other,
  };

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.onSurface.withValues(alpha: 0.06),
      ),
      child: Icon(iconFor(platform), size: size / 2, color: s.onSurface),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final PairedDevice device;
  final DeviceSyncInfo info;
  final List<String>? groups;
  final VoidCallback onTap;
  final gen.AppLocalizations loc;

  const _DeviceRow({
    required this.device,
    required this.info,
    required this.groups,
    required this.onTap,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final line = deviceSyncLine(context, loc, device, info);
    final groupLine = groups == null || groups!.isEmpty
        ? null
        : groups!.join(', ');

    return Semantics(
      button: true,
      label: [device.deviceName, line, ?groupLine].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                DeviceAvatar(platform: device.platform),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          DeviceSyncDot(health: deviceSyncHealth(info)),
                          Flexible(
                            child: Text(
                              line,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: s.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (groupLine != null)
                        Text(
                          groupLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: s.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: s.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
