import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';

import 'bluetooth_sync_factory.dart';

/// Shared "overall sync health" polling behind both [SettingsSyncBadge] and
/// [SyncStatusIcon]:
/// - [anyChannelEnabled]: at least one sync channel (LAN, Bluetooth, cloud)
///   is turned on
/// - [hasError]: the last sync attempt failed
///
/// Seeds from [SyncOrchestrator.getHistory] on load (so a failure from
/// before this widget mounted, e.g. app restart, still surfaces) and then
/// stays live via [SyncOrchestrator.events].
mixin _SyncStatusMixin<T extends StatefulWidget> on State<T> {
  static const greenColor = Color(0xFF2E7D32);
  static const ochreColor = Color(0xFFB8860B);

  SyncOrchestrator get orchestrator;

  StreamSubscription<SyncEvent>? _eventSub;
  bool anyChannelEnabled = false;
  bool hasError = false;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    _eventSub = orchestrator.events.listen(_onEvent);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final lan = await orchestrator.isLanSyncEnabled();
    final bt =
        BluetoothSyncFactory.isEnabled &&
        await BluetoothSyncFactory.isUserEnabled();
    final cloudChannel = orchestrator.cloudChannel;
    final cloud = cloudChannel != null && await cloudChannel.isEnabled();

    final history = await orchestrator.getHistory(limit: 1);
    final lastHadError =
        history.isNotEmpty && ((history.first['errors'] as int?) ?? 0) > 0;

    if (mounted) {
      setState(() {
        anyChannelEnabled = lan || bt || cloud;
        hasError = lastHadError;
        loaded = true;
      });
    }
  }

  void _onEvent(SyncEvent event) {
    if (!mounted) return;
    setState(() {
      if (event is SyncFailed) hasError = true;
      if (event is SyncCompleted) hasError = event.result.errors > 0;
    });
  }
}

/// Small colored dot overlaid on [child] summarizing overall sync health at
/// a glance, without a dedicated history button/row taking up space:
/// - green: at least one sync channel is enabled and the last sync had no
///   errors
/// - ochre: the last sync attempt failed, to draw the user's attention
/// - no dot at all: no sync channel is enabled — nothing to report
///
/// Wrap the icon glyph itself (e.g. the `Icon` passed to `IconButton.icon`),
/// not the surrounding button/tap-target — otherwise the dot anchors to the
/// larger tap-target's corner and ends up floating away from the icon.
///
/// Tapping the wrapped widget behaves exactly as it did before (opening
/// Settings, navigating to the Sync page, ...); sync history remains
/// reachable from Settings → Sync.
class SettingsSyncBadge extends StatefulWidget {
  final SyncOrchestrator orchestrator;
  final Widget child;

  const SettingsSyncBadge({
    super.key,
    required this.orchestrator,
    required this.child,
  });

  @override
  State<SettingsSyncBadge> createState() => _SettingsSyncBadgeState();
}

class _SettingsSyncBadgeState extends State<SettingsSyncBadge>
    with _SyncStatusMixin {
  @override
  SyncOrchestrator get orchestrator => widget.orchestrator;

  @override
  Widget build(BuildContext context) {
    if (!loaded || !anyChannelEnabled) return widget.child;

    final ringColor = Theme.of(context).colorScheme.outlineVariant;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor),
          ),
          child: widget.child,
        ),
        // Alignment(cos45°, sin45°) lands the dot's center exactly on the
        // ring's edge, whatever the wrapped icon's actual size — unlike a
        // fixed pixel offset from the (square) bounding box's corner, which
        // sits past the circle and leaves a gap.
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.9071, 0.9071),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasError
                    ? _SyncStatusMixin.ochreColor
                    : _SyncStatusMixin.greenColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// An [Icon] tinted to summarize overall sync health, in place of the
/// neutral [defaultColor] when at least one sync channel is enabled:
/// green when the last sync had no errors, ochre when it failed or a sync
/// is still pending. See [_SyncStatusMixin] for how that state is tracked.
class SyncStatusIcon extends StatefulWidget {
  final SyncOrchestrator orchestrator;
  final IconData icon;
  final double? size;
  final Color? defaultColor;

  const SyncStatusIcon({
    super.key,
    required this.orchestrator,
    required this.icon,
    this.size,
    this.defaultColor,
  });

  @override
  State<SyncStatusIcon> createState() => _SyncStatusIconState();
}

class _SyncStatusIconState extends State<SyncStatusIcon>
    with _SyncStatusMixin {
  @override
  SyncOrchestrator get orchestrator => widget.orchestrator;

  @override
  Widget build(BuildContext context) {
    final color = loaded && anyChannelEnabled
        ? (hasError ? _SyncStatusMixin.ochreColor : _SyncStatusMixin.greenColor)
        : widget.defaultColor;
    return Icon(widget.icon, size: widget.size, color: color);
  }
}
