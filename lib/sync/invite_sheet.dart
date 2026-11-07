import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:qr_flutter/qr_flutter.dart';

/// Modal bottom sheet inviting another phone into one group, over every
/// transport at once: a QR code for the same Wi-Fi (when Wi-Fi sync is on)
/// and, when [bluetooth] is given, visible to nearby phones over Bluetooth
/// for as long as it's open. The other phone joins from Settings ›
/// Synchronization › Sync with others › Join a group ([JoinGroupPage]).
///
/// The QR code is only valid for [PairingPayload.validityMs]: a countdown
/// is shown under it, then a prompt to make a new one.
///
/// Closes by itself, with a toast, once the other phone has joined: on the
/// QR pairing ([PeerPaired] on "lan"), or once the Bluetooth exchange that
/// follows a Bluetooth pairing has finished.
class InviteSheet extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  /// The group this invites to: pairing grants the other phone access to
  /// this group only.
  final String groupId;
  final String groupTitle;

  /// Whether Wi-Fi sync is on, so the QR code can be used.
  final bool wifiEnabled;

  /// A channel for this sheet alone (it stops it when closed), or null
  /// where Bluetooth isn't available (F-Droid build).
  final BluetoothSyncChannel? bluetooth;

  const InviteSheet({
    super.key,
    required this.orchestrator,
    required this.groupId,
    required this.groupTitle,
    required this.wifiEnabled,
    this.bluetooth,
  });

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

enum _NearbyState { visible, syncing, denied, failed }

class _InviteSheetState extends State<InviteSheet> {
  Future<PairingPayload?>? _qr;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  StreamSubscription<SyncEvent>? _syncEvents;
  StreamSubscription<BluetoothPeerEvent>? _btEvents;
  _NearbyState _nearby = _NearbyState.visible;

  /// The phone that paired over Bluetooth, while its exchange runs.
  String? _btPeerName;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    if (widget.wifiEnabled) _generate();
    _syncEvents = widget.orchestrator.events.listen(_onSyncEvent);
    final bt = widget.bluetooth;
    if (bt != null) {
      _btEvents = bt.events.listen(_onBluetoothEvent);
      bt
          .startAdvertising(
            groupId: widget.groupId,
            groupTitle: widget.groupTitle,
          )
          .catchError((Object e) {
            if (!mounted) return;
            setState(
              () => _nearby = e is BluetoothPermissionDeniedException
                  ? _NearbyState.denied
                  : _NearbyState.failed,
            );
          });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _syncEvents?.cancel();
    _btEvents?.cancel();
    final bt = widget.bluetooth;
    if (bt != null) unawaited(bt.stopAll().then((_) => bt.dispose()));
    super.dispose();
  }

  void _generate() {
    _ticker?.cancel();
    setState(() {
      _qr = widget.orchestrator
          .buildOwnPairingPayload(
            groupId: widget.groupId,
            groupTitle: widget.groupTitle,
          )
          .then((payload) {
            _startCountdown(payload);
            return payload;
          });
    });
  }

  void _startCountdown(PairingPayload? payload) {
    if (payload == null) return;

    void tick() {
      final remaining = Duration(
        milliseconds: payload.expiresAtMs - SyncClock.nowMs(),
      );
      if (!mounted) return;
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }

    tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _onSyncEvent(SyncEvent event) {
    if (event is! PeerPaired || event.groupId != widget.groupId) return;
    if (!mounted) return;
    if (event.channel == 'bluetooth') {
      // The data follows on the same connection: wait for it.
      setState(() {
        _btPeerName = event.deviceName;
        _nearby = _NearbyState.syncing;
      });
      return;
    }
    _close(event.deviceName);
  }

  void _onBluetoothEvent(BluetoothPeerEvent event) {
    if (!mounted) return;
    switch (event) {
      case BtSyncCompleted():
        // Let the answer leave the phone before Bluetooth stops.
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _close(_btPeerName ?? '');
        });
      case BtSyncError(:final error):
        LoggerService.debug('Bluetooth invite error: $error', name: 'ui.sync');
        setState(() => _nearby = _NearbyState.failed);
      default:
        break;
    }
  }

  void _close(String deviceName) {
    if (_closing) return;
    _closing = true;
    final loc = gen.AppLocalizations.of(context);
    AppToast.show(
      context,
      deviceName.isEmpty
          ? loc.sync_bt_completed
          : loc.sync_join_done(deviceName),
      type: ToastType.success,
    );
    Navigator.of(context).pop();
  }

  String _formatCountdown(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CaravellaBottomSheetScaffold(
      title: loc.sync_invite_title(widget.groupTitle),
      scrollable: true,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.sync_invite_other_phone,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildQr(context, loc),
            if (widget.bluetooth != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildNearby(context, loc),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              loc.sync_invite_closes,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQr(BuildContext context, gen.AppLocalizations loc) {
    if (!widget.wifiEnabled) {
      return _message(context, Icons.qr_code_2, loc.sync_invite_qr_off);
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<PairingPayload?>(
      future: _qr,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 252,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final payload = snapshot.data;
        if (payload == null) {
          return _message(context, Icons.wifi_off, loc.sync_qr_no_network);
        }
        if (_remaining <= Duration.zero) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _message(
                context,
                Icons.timer_off_outlined,
                loc.sync_qr_expired_desc,
              ),
              FilledButton.tonalIcon(
                onPressed: _generate,
                icon: const Icon(Icons.refresh),
                label: Text(loc.sync_qr_regenerate_button),
              ),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: payload.toQrData(),
                size: 220,
                backgroundColor: Colors.white,
                semanticsLabel: loc.sync_qr_show_button,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              loc.sync_qr_expires_in(_formatCountdown(_remaining)),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (payload.isLikelyUnreachableEmulatorHost) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                loc.sync_qr_emulator_warning,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNearby(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final problem =
        _nearby == _NearbyState.denied || _nearby == _NearbyState.failed;

    final (String title, String? detail) = switch (_nearby) {
      _NearbyState.visible => (
        loc.sync_invite_nearby_title,
        loc.sync_invite_nearby_desc,
      ),
      _NearbyState.syncing => (
        loc.sync_invite_nearby_syncing(_btPeerName ?? ''),
        null,
      ),
      _NearbyState.denied => (loc.sync_bt_permission_denied, null),
      _NearbyState.failed => (loc.sync_bt_error_detail, null),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: problem
              ? colorScheme.errorContainer
              : colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (_nearby == _NearbyState.syncing)
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              Icon(
                problem ? Icons.bluetooth_disabled : Icons.bluetooth,
                color: problem
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimaryContainer,
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: problem
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
