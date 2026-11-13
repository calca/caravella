import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../bluetooth_sync_factory.dart';
import 'paired_device_sheet_parts.dart';
import 'paired_devices_list.dart';

/// One paired device: how its sync is doing, the groups it shares,
/// "Update now" (Wi-Fi first, then Bluetooth) and taking it off — off
/// [groupId] when opened from a group, forgetting it everywhere when opened
/// from Settings.
Future<void> showPairedDeviceSheet(
  BuildContext context, {
  required SyncOrchestrator orchestrator,
  required PairedDevice device,
  required DeviceSyncInfo info,
  required List<String> groupTitles,
  String? groupId,
  String? groupTitle,
}) => showAppBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => PairedDeviceSheet(
    orchestrator: orchestrator,
    device: device,
    info: info,
    groupTitles: groupTitles,
    groupId: groupId,
    groupTitle: groupTitle,
    createBluetooth: BluetoothSyncFactory.isEnabled
        ? () => BluetoothSyncFactory.createChannel(orchestrator)
        : null,
    isBluetoothEnabled: BluetoothSyncFactory.isUserEnabled,
    onTurnOnBluetooth: () => BluetoothSyncFactory.setUserEnabled(true),
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

  /// A new channel for one Bluetooth update (the sheet stops and disposes
  /// it), or null where Bluetooth isn't available (F-Droid build).
  final BluetoothSyncChannel? Function()? createBluetooth;

  /// Whether the user allows Bluetooth sync (the privacy switch); while
  /// false the sheet offers "Turn on" via [onTurnOnBluetooth]. Null: allowed.
  final Future<bool> Function()? isBluetoothEnabled;
  final Future<void> Function()? onTurnOnBluetooth;

  /// This phone's device ID, for deciding which phone requests the
  /// Bluetooth connection. Null: [DeviceIdentity].
  final String? ownDeviceId;

  /// How long "Update now" waits for the device to answer over Wi-Fi.
  static const Duration updateTimeout = Duration(seconds: 15);

  /// How long the initiating phone waits, after a failed Bluetooth request,
  /// for the other direction to succeed before trying again.
  static const Duration collisionGrace = Duration(seconds: 3);

  /// Times the initiating phone requests the Bluetooth connection.
  static const int maxBluetoothAttempts = 2;

  /// How long "Received N, sent M" stays before the sheet closes.
  static const Duration doneDelay = Duration(milliseconds: 1500);

  const PairedDeviceSheet({
    super.key,
    required this.orchestrator,
    required this.device,
    required this.info,
    required this.groupTitles,
    this.groupId,
    this.groupTitle,
    this.createBluetooth,
    this.isBluetoothEnabled,
    this.onTurnOnBluetooth,
    this.ownDeviceId,
  });

  @override
  State<PairedDeviceSheet> createState() => _PairedDeviceSheetState();
}

class _PairedDeviceSheetState extends State<PairedDeviceSheet> {
  static const _tag = 'ui.sync';

  DeviceUpdatePhase _phase = DeviceUpdatePhase.idle;
  bool? _wifi;
  bool _wifiWasOff = false;
  String? _problem;
  bool _turningOnBluetooth = false;

  // Wi-Fi attempt
  StreamSubscription<SyncEvent>? _events;
  Timer? _timeout;
  Completer<String?>? _wifiAttempt;

  // Bluetooth step
  BluetoothSyncChannel? _bt;
  StreamSubscription<BluetoothPeerEvent>? _btEvents;
  String? _btProblem;
  String? _peerEndpoint;
  bool _requested = false;
  int _attempts = 0;
  SyncResult? _btResult;
  Timer? _graceTimer;
  Timer? _closeTimer;

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
    _graceTimer?.cancel();
    _closeTimer?.cancel();
    final attempt = _wifiAttempt;
    if (attempt != null && !attempt.isCompleted) attempt.complete(null);
    _stopBluetooth();
    super.dispose();
  }

  String get _name => widget.device.deviceName;
  bool get _bluetoothAvailable => widget.createBluetooth != null;

  // ---------------------------------------------------------------------------
  // Update now: Wi-Fi first, then Bluetooth
  // ---------------------------------------------------------------------------

  Future<void> _update() async {
    final loc = gen.AppLocalizations.of(context);
    _wifiWasOff = _wifi != true;
    if (_wifi == true) {
      setState(() {
        _phase = DeviceUpdatePhase.wifi;
        _problem = null;
      });
      final problem = await _tryWifi(loc);
      if (!mounted) return;
      if (problem == null) return _finish();
      if (!_bluetoothAvailable) {
        setState(() {
          _phase = DeviceUpdatePhase.idle;
          _problem = problem;
        });
        return;
      }
    }
    await _startBluetooth();
  }

  /// Triggers a Wi-Fi sync and waits up to [PairedDeviceSheet.updateTimeout]
  /// for this device to answer. Null when it did, else what went wrong.
  Future<String?> _tryWifi(gen.AppLocalizations loc) {
    final attempt = Completer<String?>();
    _wifiAttempt = attempt;
    void finish(String? problem) {
      _events?.cancel();
      _timeout?.cancel();
      if (!attempt.isCompleted) attempt.complete(problem);
    }

    _events = widget.orchestrator.events.listen((event) {
      if (event is SyncCompleted &&
          event.result.peerId == widget.device.deviceId) {
        finish(event.result.errors > 0 ? loc.sync_device_failed : null);
      } else if (event is SyncFailed &&
          event.peerId == widget.device.deviceId) {
        finish(
          event.unreachable
              ? loc.sync_device_unreachable(_name)
              : loc.sync_device_failed,
        );
      }
    });
    _timeout = Timer(
      PairedDeviceSheet.updateTimeout,
      () => finish(loc.sync_device_unreachable(_name)),
    );
    widget.orchestrator.triggerManualSync('lan').then<void>((_) {}).catchError((
      Object e,
      StackTrace st,
    ) {
      LoggerService.error(
        'Manual update of $_name failed',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      finish(loc.sync_device_failed);
    });
    return attempt.future;
  }

  void _finish() {
    if (!mounted) return;
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).sync_join_done(_name),
      type: ToastType.success,
    );
    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------------
  // Bluetooth step: both phones advertise and discover; the one with the
  // smaller device ID requests the connection, the other waits for it.
  // ---------------------------------------------------------------------------

  Future<void> _startBluetooth() async {
    final enabled = await widget.isBluetoothEnabled?.call() ?? true;
    if (!mounted) return;
    if (!enabled) {
      setState(() => _phase = DeviceUpdatePhase.needsBluetooth);
      return;
    }
    await _beginBluetooth();
  }

  Future<void> _turnOnBluetooth() async {
    final turnOn = widget.onTurnOnBluetooth;
    if (turnOn == null) return;
    setState(() => _turningOnBluetooth = true);
    await turnOn();
    if (!mounted) return;
    setState(() => _turningOnBluetooth = false);
    await _beginBluetooth();
  }

  Future<void> _beginBluetooth() async {
    final bt = widget.createBluetooth?.call();
    if (bt == null) {
      setState(() {
        _phase = DeviceUpdatePhase.idle;
        _problem = gen.AppLocalizations.of(context).sync_bt_error_detail;
      });
      return;
    }
    _stopBluetooth();
    _graceTimer?.cancel();
    _bt = bt;
    _btEvents = bt.events.listen(_onBluetoothEvent);
    setState(() {
      _phase = DeviceUpdatePhase.searching;
      _problem = null;
      _btProblem = null;
      _peerEndpoint = null;
      _requested = false;
      _attempts = 0;
      _btResult = null;
    });
    try {
      await bt.startUpdate(targetDeviceId: widget.device.deviceId);
    } catch (e, st) {
      LoggerService.error(
        'Bluetooth update with $_name could not start',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      if (!mounted || _bt != bt) return;
      final loc = gen.AppLocalizations.of(context);
      setState(() {
        _phase = DeviceUpdatePhase.failed;
        _btProblem = e is BluetoothPermissionDeniedException
            ? loc.sync_bt_permission_denied
            : loc.sync_bt_error_detail;
      });
    }
  }

  void _onBluetoothEvent(BluetoothPeerEvent event) {
    if (!mounted || _phase == DeviceUpdatePhase.done) return;
    switch (event) {
      case PeerFound(:final endpointId, :final updateDeviceId):
        // Only the paired device being updated counts; invitations and
        // other phones are ignored.
        if (updateDeviceId != widget.device.deviceId) {
          LoggerService.debug(
            'Ignoring nearby $endpointId during an update',
            name: _tag,
          );
          return;
        }
        _peerEndpoint = endpointId;
        if (_phase == DeviceUpdatePhase.searching) {
          setState(() => _phase = DeviceUpdatePhase.exchanging);
        }
        _requestExchange();
      case PeerLost(:final endpointId):
        if (endpointId == _peerEndpoint &&
            !_requested &&
            _phase == DeviceUpdatePhase.exchanging) {
          setState(() {
            _peerEndpoint = null;
            _phase = DeviceUpdatePhase.searching;
          });
        }
      case BtSyncCompleted(:final result):
        // Our own request finishing, or the other phone's arriving.
        if (result.peerId == widget.device.deviceId && result.errors == 0) {
          _completeBluetooth(result);
        }
      default:
        break;
    }
  }

  /// Requests the connection if this phone is the one that does (the
  /// smaller device ID); the other only waits for it.
  void _requestExchange() {
    final bt = _bt;
    final endpoint = _peerEndpoint;
    if (bt == null ||
        endpoint == null ||
        _requested ||
        _phase != DeviceUpdatePhase.exchanging) {
      return;
    }
    final ownId = widget.ownDeviceId ?? DeviceIdentity.instance.deviceId;
    if (!BluetoothUpdate.initiates(ownId, widget.device.deviceId)) return;

    _requested = true;
    _attempts++;
    bt
        .syncWithPeer(endpoint)
        .then<void>((result) {
          if (!mounted || _bt != bt || _phase == DeviceUpdatePhase.done) return;
          if (result.errors == 0) {
            _completeBluetooth(result);
          } else {
            _requestFailed();
          }
        })
        .catchError((Object e, StackTrace st) {
          LoggerService.error(
            'Bluetooth request to $_name failed',
            name: _tag,
            error: e,
            stackTrace: st,
          );
          if (mounted && _bt == bt && _phase != DeviceUpdatePhase.done) {
            _requestFailed();
          }
        });
  }

  /// A failed request may only mean both directions collided and the other
  /// one went through: wait a moment for that before trying again, then
  /// give up.
  void _requestFailed() {
    _requested = false;
    _graceTimer?.cancel();
    _graceTimer = Timer(PairedDeviceSheet.collisionGrace, () {
      if (!mounted || _phase == DeviceUpdatePhase.done) return;
      if (_attempts < PairedDeviceSheet.maxBluetoothAttempts &&
          _peerEndpoint != null) {
        _requestExchange();
        return;
      }
      setState(() {
        _phase = DeviceUpdatePhase.failed;
        _btProblem = gen.AppLocalizations.of(context).sync_bt_error_detail;
      });
    });
  }

  void _completeBluetooth(SyncResult result) {
    if (!mounted || _phase == DeviceUpdatePhase.done) return;
    _graceTimer?.cancel();
    setState(() {
      _phase = DeviceUpdatePhase.done;
      _btResult = result;
    });
    _closeTimer = Timer(PairedDeviceSheet.doneDelay, _finish);
  }

  void _cancelBluetooth() {
    _graceTimer?.cancel();
    _stopBluetooth();
    setState(() {
      _phase = DeviceUpdatePhase.idle;
      _peerEndpoint = null;
      _requested = false;
    });
  }

  /// Stops Bluetooth and releases the channel; also when the sheet closes.
  void _stopBluetooth() {
    _btEvents?.cancel();
    _btEvents = null;
    final bt = _bt;
    _bt = null;
    if (bt != null) unawaited(bt.stopAll().then((_) => bt.dispose()));
  }

  // ---------------------------------------------------------------------------
  // Taking it off
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final info = widget.info;

    final header = Row(
      children: [
        DeviceAvatar(platform: widget.device.platform, size: 48),
        const SizedBox(width: AppSpacing.md),
        DeviceSyncDot(health: deviceSyncHealth(info)),
        Expanded(
          child: Text(
            deviceSyncLine(context, loc, widget.device, info),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: s.onSurfaceVariant),
          ),
        ),
      ],
    );

    return CaravellaBottomSheetScaffold(
      title: _name,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: AppSpacing.md),
          if (_phase.inBluetoothStep)
            BluetoothUpdateSteps(
              phase: _phase,
              result: _btResult,
              problem: _btProblem,
              wifiWasOff: _wifiWasOff,
              instruction: widget.groupTitle == null
                  ? loc.sync_update_bt_instruction_settings(_name)
                  : loc.sync_update_bt_instruction_group(
                      _name,
                      widget.groupTitle!,
                    ),
              onRetry: _beginBluetooth,
              onCancel: _cancelBluetooth,
            )
          else ...[
            DeviceFactsCard(
              lastSyncAt: info.lastSyncAt,
              pairedAt: widget.device.pairedAt,
              groupTitles: widget.groupTitles,
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._actions(context, loc),
          ],
        ],
      ),
    );
  }

  /// "Update now", its hint, the "turn on Bluetooth" panel and "Take off".
  List<Widget> _actions(BuildContext context, gen.AppLocalizations loc) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final wifi = _wifi;
    final trying = _phase == DeviceUpdatePhase.wifi;
    final canUpdate = wifi != null && (wifi || _bluetoothAvailable) && !trying;

    final hint =
        _problem ??
        (wifi == false
            ? (_bluetoothAvailable
                  ? loc.sync_update_bt_hint
                  : loc.sync_device_update_wifi_off)
            : (_bluetoothAvailable
                  ? loc.sync_device_update_hint_bt
                  : loc.sync_device_update_hint));

    return [
      FilledButton.icon(
        onPressed: canUpdate ? _update : null,
        icon: trying
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
          hint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: _problem != null ? s.error : s.onSurfaceVariant,
          ),
        ),
      ),
      if (_phase == DeviceUpdatePhase.needsBluetooth) ...[
        const SizedBox(height: AppSpacing.md),
        BluetoothOffPanel(
          onTurnOn: widget.onTurnOnBluetooth != null ? _turnOnBluetooth : null,
          busy: _turningOnBluetooth,
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton.icon(
        onPressed: trying ? null : _takeOff,
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
    ];
  }
}
