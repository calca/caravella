import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera scanner for pairing with another device's QR code.
///
/// Pops with `true` if pairing succeeded, `false` otherwise.
class QrPairScanPage extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const QrPairScanPage({super.key, required this.orchestrator});

  @override
  State<QrPairScanPage> createState() => _QrPairScanPageState();
}

class _QrPairScanPageState extends State<QrPairScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling || capture.barcodes.isEmpty) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    final payload = PairingPayload.tryParse(raw);
    if (payload == null) return; // Not a pairing QR — keep scanning.

    setState(() => _handling = true);
    await _controller.stop();

    if (!mounted) return;
    final loc = gen.AppLocalizations.of(context);

    if (payload.isExpired) {
      AppToast.show(context, loc.sync_qr_pair_expired, type: ToastType.error);
      Navigator.of(context).pop(false);
      return;
    }

    if (payload.isLikelyUnreachableEmulatorHost) {
      AppToast.show(
        context,
        loc.sync_qr_pair_emulator_host,
        type: ToastType.error,
      );
      Navigator.of(context).pop(false);
      return;
    }

    final success = await widget.orchestrator.pairWithScannedPayload(payload);

    if (!mounted) return;

    AppToast.show(
      context,
      success
          ? loc.sync_qr_pair_success(payload.deviceName)
          : loc.sync_qr_pair_failed,
      type: success ? ToastType.success : ToastType.error,
    );

    Navigator.of(context).pop(success);
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(loc.sync_qr_scan_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_handling)
            const ColoredBox(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.black54,
              child: Text(
                loc.sync_qr_scan_description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
