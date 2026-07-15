import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:qr_flutter/qr_flutter.dart';

/// Modal bottom sheet showing this device's pairing QR code for another
/// device (on the same Wi-Fi network) to scan.
class QrPairShowSheet extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const QrPairShowSheet({super.key, required this.orchestrator});

  @override
  State<QrPairShowSheet> createState() => _QrPairShowSheetState();
}

class _QrPairShowSheetState extends State<QrPairShowSheet> {
  late final Future<PairingPayload?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.orchestrator.buildOwnPairingPayload();
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
            ],
          );
        },
      ),
    );
  }
}
