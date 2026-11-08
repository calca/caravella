import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import 'paired_devices_list.dart';

/// One paired device: how its sync is doing, the groups it shares,
/// "Update now" over Wi-Fi, and taking it off — off [groupId] when opened
/// from a group, forgetting it everywhere when opened from Settings.
Future<void> showPairedDeviceSheet(
  BuildContext context, {
  required SyncOrchestrator orchestrator,
  required PairedDevice device,
  required DeviceSyncInfo info,
  required List<String> groupTitles,
  String? groupId,
  String? groupTitle,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => PairedDeviceSheet(
    orchestrator: orchestrator,
    device: device,
    info: info,
    groupTitles: groupTitles,
    groupId: groupId,
    groupTitle: groupTitle,
  ),
);

class PairedDeviceSheet extends StatefulWidget {
  final SyncOrchestrator orchestrator;
  final PairedDevice device;
  final DeviceSyncInfo info;
  final List<String> groupTitles;

  /// The group it was opened from: "Take off «groupTitle»" revokes only
  /// that one. Null (from Settings): "Forget this device" removes it.
  final String? groupId;
  final String? groupTitle;

  /// How long "Update now" waits for the device to answer over Wi-Fi.
  static const Duration updateTimeout = Duration(seconds: 15);

  const PairedDeviceSheet({
    super.key,
    required this.orchestrator,
    required this.device,
    required this.info,
    required this.groupTitles,
    this.groupId,
    this.groupTitle,
  });

  @override
  State<PairedDeviceSheet> createState() => _PairedDeviceSheetState();
}

class _PairedDeviceSheetState extends State<PairedDeviceSheet> {
  bool? _wifi;
  bool _updating = false;
  String? _problem;
  StreamSubscription<SyncEvent>? _events;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    widget.orchestrator.isLanSyncEnabled().then((on) {
      if (mounted) setState(() => _wifi = on);
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    _timeout?.cancel();
    super.dispose();
  }

  String get _name => widget.device.deviceName;

  Future<void> _update() async {
    final loc = gen.AppLocalizations.of(context);
    setState(() {
      _updating = true;
      _problem = null;
    });
    void finish({String? problem}) {
      _events?.cancel();
      _timeout?.cancel();
      if (!mounted) return;
      if (problem == null) {
        AppToast.show(
          context,
          loc.sync_join_done(_name),
          type: ToastType.success,
        );
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _updating = false;
        _problem = problem;
      });
    }

    _events = widget.orchestrator.events.listen((event) {
      if (event is SyncCompleted &&
          event.result.peerId == widget.device.deviceId) {
        finish(
          problem: event.result.errors > 0 ? loc.sync_device_failed : null,
        );
      } else if (event is SyncFailed &&
          event.peerId == widget.device.deviceId) {
        finish(
          problem: event.unreachable
              ? loc.sync_device_unreachable(_name)
              : loc.sync_device_failed,
        );
      }
    });
    _timeout = Timer(
      PairedDeviceSheet.updateTimeout,
      () => finish(problem: loc.sync_device_unreachable(_name)),
    );
    try {
      await widget.orchestrator.triggerManualSync('lan');
    } catch (e, st) {
      LoggerService.error(
        'Manual update of $_name failed',
        name: 'ui.sync',
        error: e,
        stackTrace: st,
      );
      finish(problem: loc.sync_device_failed);
    }
  }

  Future<void> _takeOff() async {
    final loc = gen.AppLocalizations.of(context);
    final groupId = widget.groupId;
    final group = widget.groupTitle ?? '';
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => Material3Dialog(
            title: Text(
              groupId != null
                  ? loc.sync_device_remove_title(_name, group)
                  : loc.sync_device_forget_title(_name),
            ),
            content: Text(
              groupId != null
                  ? loc.sync_device_remove_body
                  : loc.sync_device_forget_body,
            ),
            actions: [
              Material3DialogActions.cancel(context, loc.cancel),
              Material3DialogActions.destructive(
                context,
                groupId != null
                    ? loc.sync_device_remove_confirm
                    : loc.sync_device_forget_confirm,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    if (groupId != null) {
      await widget.orchestrator.revokeGroupAccess(
        widget.device.deviceId,
        groupId,
      );
    } else {
      await widget.orchestrator.removePairedDevice(widget.device.deviceId);
    }
    if (!mounted) return;
    AppToast.show(
      context,
      groupId != null
          ? loc.sync_device_removed(_name)
          : loc.sync_device_forgotten(_name),
      type: ToastType.success,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final info = widget.info;
    final last = info.lastSyncAt;
    final wifi = _wifi;

    Widget fact(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: s.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return CaravellaBottomSheetScaffold(
      title: _name,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DeviceAvatar(platform: widget.device.platform, size: 48),
              const SizedBox(width: AppSpacing.md),
              DeviceSyncDot(health: deviceSyncHealth(info)),
              Expanded(
                child: Text(
                  deviceSyncLine(context, loc, widget.device, info),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: s.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: s.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                fact(
                  loc.sync_device_last_update,
                  last == null
                      ? loc.sync_device_never_short
                      : DateFormat.MMMd(locale).add_Hm().format(last.toLocal()),
                ),
                fact(
                  loc.sync_device_paired_on,
                  DateFormat.yMMMd(
                    locale,
                  ).format(widget.device.pairedAt.toLocal()),
                ),
                if (widget.groupTitles.isNotEmpty)
                  fact(loc.sync_device_groups, widget.groupTitles.join(', ')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: wifi == true && !_updating ? _update : null,
            icon: _updating
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: s.onSurface.withValues(alpha: 0.38),
                    ),
                  )
                : const Icon(Icons.sync),
            label: Text(loc.sync_device_update_now),
          ),
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            liveRegion: true,
            child: Text(
              _problem ??
                  (wifi == false
                      ? loc.sync_device_update_wifi_off
                      : loc.sync_device_update_hint),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _problem != null ? s.error : s.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _updating ? null : _takeOff,
            style: OutlinedButton.styleFrom(
              foregroundColor: s.error,
              side: BorderSide(color: s.error),
            ),
            icon: Icon(
              widget.groupId != null
                  ? Icons.person_remove_outlined
                  : Icons.delete_outline,
            ),
            label: Text(
              widget.groupId != null
                  ? loc.sync_device_remove_from(widget.groupTitle ?? '')
                  : loc.sync_device_forget,
            ),
          ),
        ],
      ),
    );
  }
}
