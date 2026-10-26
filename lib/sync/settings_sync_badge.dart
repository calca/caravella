import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_factory.dart';
import 'sync_settings_screen.dart';

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
  SyncOrchestrator get orchestrator;

  StreamSubscription<SyncEvent>? _eventSub;
  bool anyChannelEnabled = false;
  bool hasError = false;
  bool syncing = false;
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
      if (event is SyncStarted) syncing = true;
      if (event is SyncFailed) {
        syncing = false;
        // A peer out of reach is normal for device-to-device sync.
        if (!event.unreachable) hasError = true;
      }
      if (event is SyncCompleted) {
        syncing = false;
        hasError = event.result.errors > 0;
      }
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

    final colorScheme = Theme.of(context).colorScheme;
    final ringColor = colorScheme.outlineVariant;

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
                color: hasError ? colorScheme.warning : colorScheme.success,
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

class _SyncStatusIconState extends State<SyncStatusIcon> with _SyncStatusMixin {
  @override
  SyncOrchestrator get orchestrator => widget.orchestrator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = loaded && anyChannelEnabled
        ? (hasError ? colorScheme.warning : colorScheme.success)
        : widget.defaultColor;
    return Icon(widget.icon, size: widget.size, color: color);
  }
}

/// Home's sync button, next to the settings gear: a raised round button
/// with the sync arrows (in the text color, like the gear) that turn while
/// syncing; after a failure an ochre dot in its corner, the same language
/// as the groups' "Shared" badge ([GroupSyncBadge]). It opens the sync
/// settings. Shown only while syncing or after a failure (hidden when all
/// is fine or no sync channel is enabled).
class HomeSyncButton extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const HomeSyncButton({super.key, required this.orchestrator});

  @override
  State<HomeSyncButton> createState() => _HomeSyncButtonState();
}

class _HomeSyncButtonState extends State<HomeSyncButton>
    with _SyncStatusMixin, SingleTickerProviderStateMixin {
  @override
  SyncOrchestrator get orchestrator => widget.orchestrator;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only when there is something to tell: a sync running or a failure.
    // "All fine" is the normal state and needs no icon in the header.
    if (!loaded || !anyChannelEnabled || (!syncing && !hasError)) {
      if (_spin.isAnimating) _spin.stop();
      return const SizedBox.shrink();
    }
    final s = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    if (syncing && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!syncing && _spin.isAnimating) {
      _spin.stop();
      _spin.value = 0;
    }

    // Visible only while syncing or after a failure (see above).
    final state = syncing ? gloc.sync_state_syncing : gloc.sync_state_error;

    Widget glyph = Icon(Icons.sync_rounded, color: s.onSurface);
    if (syncing) {
      // Material's sync arrows turn counterclockwise.
      glyph = RotationTransition(
        turns: Tween(begin: 0.0, end: -1.0).animate(_spin),
        child: glyph,
      );
    }

    final button = Material(
      color: s.raisedSurface,
      shape: const CircleBorder(),
      child: IconButton(
        icon: glyph,
        tooltip: '${gloc.sync_title}, $state',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SyncSettingsScreen(orchestrator: orchestrator),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: syncing
          ? button
          : Stack(
              clipBehavior: Clip.none,
              children: [
                button,
                // Failure: ochre dot in the corner, ringed by the button's
                // surface so it stands off the arrows.
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.warning,
                        border: Border.all(color: s.raisedSurface, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
