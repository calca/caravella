import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';

import 'bluetooth_sync_factory.dart';

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

class _SettingsSyncBadgeState extends State<SettingsSyncBadge> {
  static const _greenDot = Color(0xFF2E7D32);
  static const _ochreDot = Color(0xFFB8860B);

  StreamSubscription<SyncEvent>? _eventSub;
  bool _anyChannelEnabled = false;
  bool _hasError = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    _eventSub = widget.orchestrator.events.listen(_onEvent);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final lan = await widget.orchestrator.isLanSyncEnabled();
    final bt = BluetoothSyncFactory.isEnabled &&
        await BluetoothSyncFactory.isUserEnabled();
    final cloudChannel = widget.orchestrator.cloudChannel;
    final cloud = cloudChannel != null && await cloudChannel.isEnabled();

    // Seed the initial error state from the last recorded sync, so a
    // failure from before this widget mounted (e.g. app restart) still
    // shows the ochre dot instead of resetting to green.
    final history = await widget.orchestrator.getHistory(limit: 1);
    final lastHadError =
        history.isNotEmpty && ((history.first['errors'] as int?) ?? 0) > 0;

    if (mounted) {
      setState(() {
        _anyChannelEnabled = lan || bt || cloud;
        _hasError = lastHadError;
        _loaded = true;
      });
    }
  }

  void _onEvent(SyncEvent event) {
    if (!mounted) return;
    setState(() {
      if (event is SyncFailed) _hasError = true;
      if (event is SyncCompleted) _hasError = event.result.errors > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || !_anyChannelEnabled) return widget.child;

    return Badge(
      backgroundColor: _hasError ? _ochreDot : _greenDot,
      smallSize: 8,
      alignment: AlignmentDirectional.topEnd,
      offset: const Offset(2, -2),
      child: widget.child,
    );
  }
}
