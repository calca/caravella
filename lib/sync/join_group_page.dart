import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// "Join a group": the receiving side of [InviteSheet], over every
/// transport at once. The camera reads the QR code another phone shows
/// (same Wi-Fi), and, when [bluetooth] is given, the panel at the bottom
/// lists the nearby phones with "Invite" open, to join (or, when already
/// paired, update) over Bluetooth — once the user allows Bluetooth
/// ([bluetoothEnabled]; otherwise a "Turn on" button, [onTurnOnBluetooth]).
///
/// Pops with `true` once joined. A QR code that can't be used (expired,
/// from an emulator, pairing failed) is explained in the panel with "Scan
/// again"; a Bluetooth exchange that fails, under the nearby list.
class JoinGroupPage extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  /// Whether Wi-Fi sync is on: the QR code pairs over the Wi-Fi.
  final bool wifiEnabled;

  /// Turns Wi-Fi sync on, from the "Turn on" button shown when it's off.
  final Future<void> Function()? onTurnOnWifi;

  /// A channel for this page alone (it stops it when closed), or null where
  /// Bluetooth isn't available (F-Droid build).
  final BluetoothSyncChannel? bluetooth;

  /// Whether the user allows Bluetooth sync (the privacy switch). While
  /// false, [bluetooth] stays off and the panel offers to turn it on.
  final bool bluetoothEnabled;

  /// Turns the Bluetooth privacy switch on, from the "Turn on" button.
  final Future<void> Function()? onTurnOnBluetooth;

  const JoinGroupPage({
    super.key,
    required this.orchestrator,
    required this.wifiEnabled,
    this.onTurnOnWifi,
    this.bluetooth,
    required this.bluetoothEnabled,
    this.onTurnOnBluetooth,
  });

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _NearbyPeer {
  final String endpointId;
  final String name;
  final String? groupTitle;

  const _NearbyPeer(this.endpointId, this.name, this.groupTitle);
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  late bool _wifi = widget.wifiEnabled;
  bool _turningOnWifi = false;

  // QR
  bool _handling = false;
  String? _qrProblem;

  // Bluetooth
  late bool _btOn = widget.bluetoothEnabled;
  bool _turningOnBluetooth = false;
  StreamSubscription<BluetoothPeerEvent>? _btEvents;
  final List<_NearbyPeer> _peers = [];
  Set<String> _pairedNames = const {};
  String? _joining;
  String? _btProblem;

  bool get _canScan => _wifi && GmsIntegrations.instance.supportsQrScanning;

  @override
  void initState() {
    super.initState();
    if (_btOn) _startBluetooth();
  }

  void _startBluetooth() {
    final bt = widget.bluetooth;
    if (bt != null) {
      _btEvents ??= bt.events.listen(_onBluetoothEvent);
      _startDiscovery();
      widget.orchestrator.getPairedDevices().then((devices) {
        if (mounted) {
          setState(
            () => _pairedNames = {for (final d in devices) d.deviceName},
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _btEvents?.cancel();
    final bt = widget.bluetooth;
    if (bt != null) unawaited(bt.stopAll().then((_) => bt.dispose()));
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // QR
  // ---------------------------------------------------------------------------

  Future<void> _onDetect(String raw) async {
    if (_handling || _qrProblem != null || _joining != null) return;

    final payload = PairingPayload.tryParse(raw);
    if (payload == null) return; // Not a pairing QR — keep scanning.

    setState(() => _handling = true);
    final loc = gen.AppLocalizations.of(context);

    if (payload.isExpired) return _failQr(loc.sync_qr_pair_expired);
    if (payload.isLikelyUnreachableEmulatorHost) {
      return _failQr(loc.sync_qr_pair_emulator_host);
    }

    final success = await widget.orchestrator.pairWithScannedPayload(payload);
    if (!mounted) return;
    if (!success) return _failQr(loc.sync_qr_pair_failed);
    _done(payload.deviceName);
  }

  void _failQr(String problem) => setState(() {
    _handling = false;
    _qrProblem = problem;
  });

  Future<void> _turnOnWifi() async {
    final turnOn = widget.onTurnOnWifi;
    if (turnOn == null) return;
    setState(() => _turningOnWifi = true);
    await turnOn();
    if (mounted) {
      setState(() {
        _turningOnWifi = false;
        _wifi = true;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Bluetooth
  // ---------------------------------------------------------------------------

  Future<void> _turnOnBluetooth() async {
    final turnOn = widget.onTurnOnBluetooth;
    if (turnOn == null) return;
    setState(() => _turningOnBluetooth = true);
    await turnOn();
    if (!mounted) return;
    setState(() {
      _turningOnBluetooth = false;
      _btOn = true;
    });
    _startBluetooth();
  }

  void _startDiscovery() {
    widget.bluetooth!.startDiscovery().catchError((Object e) {
      if (!mounted) return;
      final loc = gen.AppLocalizations.of(context);
      setState(
        () => _btProblem = e is BluetoothPermissionDeniedException
            ? loc.sync_bt_permission_denied
            : loc.sync_bt_error_detail,
      );
    });
  }

  void _onBluetoothEvent(BluetoothPeerEvent event) {
    if (!mounted) return;
    switch (event) {
      case PeerFound(:final endpointId, :final name, :final groupTitle):
        setState(() {
          _peers.removeWhere((p) => p.endpointId == endpointId);
          _peers.add(_NearbyPeer(endpointId, name, groupTitle));
        });
      case PeerLost(:final endpointId):
        if (endpointId == _joining) return;
        setState(() => _peers.removeWhere((p) => p.endpointId == endpointId));
      default:
        break;
    }
  }

  Future<void> _join(_NearbyPeer peer) async {
    setState(() {
      _joining = peer.endpointId;
      _btProblem = null;
    });
    try {
      final result = await widget.bluetooth!.syncWithPeer(peer.endpointId);
      if (!mounted) return;
      if (result.errors > 0) throw StateError('exchange had errors');
      _done(peer.name);
    } catch (e) {
      LoggerService.debug('Bluetooth join failed: $e', name: 'ui.sync');
      if (!mounted) return;
      setState(() {
        _joining = null;
        _btProblem = gen.AppLocalizations.of(context).sync_bt_error_detail;
      });
    }
  }

  void _done(String deviceName) {
    // Leaving the page: the toast is what's left to say it worked.
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).sync_join_done(deviceName),
      type: ToastType.success,
    );
    Navigator.of(context).pop(true);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return AppSystemUI.edgeToEdge(
      forceStatusBarLight: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        // The camera fills the screen, behind the nearby panel too (its
        // rounded top shows the camera); status and top bar sit above it.
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_canScan)
              GmsIntegrations.instance.buildQrScanner(
                    onDetect: _onDetect,
                    paused: _handling || _qrProblem != null || _joining != null,
                  ) ??
                  const SizedBox.shrink(),
            Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_handling)
                        const ColoredBox(
                          color: Colors.black54,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: _buildQrStatus(context, loc),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: MediaTopBar(
                          title: loc.sync_join_button,
                          backTooltip: loc.accessibility_back_button,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.bluetooth != null) _buildNearby(context, loc),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrStatus(BuildContext context, gen.AppLocalizations loc) {
    const white = TextStyle(color: Colors.white);
    if (!_wifi) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_2, color: Colors.white, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(loc.sync_join_qr_off, textAlign: TextAlign.center, style: white),
          if (widget.onTurnOnWifi != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _turningOnWifi ? null : _turnOnWifi,
              child: Text(loc.sync_join_turn_on_wifi),
            ),
          ],
        ],
      );
    }
    if (_qrProblem != null) {
      return Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(height: AppSpacing.sm),
            Text(_qrProblem!, textAlign: TextAlign.center, style: white),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => setState(() => _qrProblem = null),
              child: Text(loc.sync_qr_scan_again),
            ),
          ],
        ),
      );
    }
    return Text(
      loc.sync_join_scan_hint,
      textAlign: TextAlign.center,
      style: white,
    );
  }

  Widget _buildNearby(BuildContext context, gen.AppLocalizations loc) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: s.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.45,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            children: [
              Row(
                children: [
                  Icon(Icons.bluetooth, color: s.primary, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        loc.sync_join_nearby_title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (_btOn && _btProblem == null)
                    Text(
                      loc.sync_join_searching,
                      style: textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!_btOn)
                _buildBluetoothOff(context, loc)
              else ...[
                for (final peer in _peers) ...[
                  _buildPeer(context, loc, peer),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (_btProblem != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        _btProblem!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(color: s.error),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Text(
                      loc.sync_join_nearby_hint,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBluetoothOff(BuildContext context, gen.AppLocalizations loc) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.sync_bt_off_title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                loc.sync_bt_off_desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: s.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (widget.onTurnOnBluetooth != null) ...[
          const SizedBox(width: AppSpacing.xs),
          OutlinedButton(
            onPressed: _turningOnBluetooth ? null : _turnOnBluetooth,
            child: Text(loc.sync_join_turn_on),
          ),
        ],
      ],
    );
  }

  Widget _buildPeer(
    BuildContext context,
    gen.AppLocalizations loc,
    _NearbyPeer peer,
  ) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final paired = _pairedNames.contains(peer.name);
    final joining = _joining == peer.endpointId;
    final busy = _joining != null || _handling;
    final subtitle = peer.groupTitle != null
        ? loc.sync_invite_title(peer.groupTitle!)
        : paired
        ? loc.sync_join_peer_paired
        : null;

    void onPressed() => _join(peer);
    final label = Text(paired ? loc.sync_join_update : loc.sync_join_action);
    final spinner = SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: paired ? s.primary : s.onPrimary,
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: s.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.smartphone, color: s.onSurface),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peer.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: s.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Semantics(
            label:
                '${paired ? loc.sync_join_update : loc.sync_join_action} '
                '${peer.name}',
            excludeSemantics: true,
            button: true,
            enabled: !busy,
            onTap: busy ? null : onPressed,
            child: paired
                ? OutlinedButton(
                    onPressed: busy ? null : onPressed,
                    child: joining ? spinner : label,
                  )
                : FilledButton(
                    onPressed: busy ? null : onPressed,
                    child: joining ? spinner : label,
                  ),
          ),
        ],
      ),
    );
  }
}
