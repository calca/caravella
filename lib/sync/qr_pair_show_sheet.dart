import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:qr_flutter/qr_flutter.dart';

/// Modal bottom sheet showing this device's pairing QR code for another
/// device (on the same Wi-Fi network) to scan.
///
/// The code is only valid for [PairingPayload.validityMs] — a countdown is
/// shown next to it, and once it expires the QR is replaced with a prompt
/// to generate a new one instead of staying scannable indefinitely.
class QrPairShowSheet extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  /// The group this code shares — pairing grants the scanning device
  /// access to this group specifically, not every synced group.
  final String groupId;
  final String groupTitle;

  const QrPairShowSheet({
    super.key,
    required this.orchestrator,
    required this.groupId,
    required this.groupTitle,
  });

  @override
  State<QrPairShowSheet> createState() => _QrPairShowSheetState();
}

class _QrPairShowSheetState extends State<QrPairShowSheet> {
  Future<PairingPayload?>? _future;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _generate() {
    _ticker?.cancel();
    setState(() {
      _future = widget.orchestrator
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

    return GroupBottomSheetScaffold(
      title: loc.sync_qr_show_title,
      child: FutureBuilder<PairingPayload?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final payload = snapshot.data;
          if (payload == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, color: colorScheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    loc.sync_qr_no_network,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final expired = _remaining <= Duration.zero;

          if (expired) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_off_outlined,
                    color: colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.sync_qr_expired_title,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.sync_qr_expired_desc,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: _generate,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.sync_qr_regenerate_button),
                  ),
                ],
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.sync_qr_show_description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              if (widget.groupTitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  loc.sync_qr_sharing_group(widget.groupTitle),
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall,
                ),
              ],
              const SizedBox(height: 20),
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
                ),
              ),
              const SizedBox(height: 12),
              Text(payload.deviceName, style: textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                loc.sync_qr_expires_in(_formatCountdown(_remaining)),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              if (payload.isLikelyUnreachableEmulatorHost) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        loc.sync_qr_emulator_warning,
                        textAlign: TextAlign.start,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
