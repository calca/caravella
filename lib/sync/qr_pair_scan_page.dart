import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Full-screen camera scanner for pairing with another device's QR code.
///
/// The camera view comes from [GmsIntegrations.buildQrScanner] (ML Kit);
/// only reachable when [GmsIntegrations.supportsQrScanning] is true.
///
/// Pops with `true` if pairing succeeded. A code that can't be used
/// (expired, from an emulator, pairing failed) is explained in the panel
/// at the bottom, with "Scan again"; back leaves with `false`.
class QrPairScanPage extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const QrPairScanPage({super.key, required this.orchestrator});

  @override
  State<QrPairScanPage> createState() => _QrPairScanPageState();
}

class _QrPairScanPageState extends State<QrPairScanPage> {
  bool _handling = false;

  /// Why the last scanned code didn't pair, shown in the bottom panel.
  String? _problem;

  Future<void> _onDetect(String raw) async {
    if (_handling || _problem != null) return;

    final payload = PairingPayload.tryParse(raw);
    if (payload == null) return; // Not a pairing QR — keep scanning.

    // Pausing the scanner stops the camera.
    setState(() => _handling = true);

    if (!mounted) return;
    final loc = gen.AppLocalizations.of(context);

    if (payload.isExpired) {
      _fail(loc.sync_qr_pair_expired);
      return;
    }

    if (payload.isLikelyUnreachableEmulatorHost) {
      _fail(loc.sync_qr_pair_emulator_host);
      return;
    }

    final success = await widget.orchestrator.pairWithScannedPayload(payload);

    if (!mounted) return;

    if (!success) {
      _fail(loc.sync_qr_pair_failed);
      return;
    }
    // Leaving the page: the toast is what's left to say it worked.
    AppToast.show(
      context,
      loc.sync_qr_pair_success(payload.deviceName),
      type: ToastType.success,
    );
    Navigator.of(context).pop(true);
  }

  void _fail(String problem) => setState(() {
    _handling = false;
    _problem = problem;
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return AppSystemUI.edgeToEdge(
      forceStatusBarLight: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GmsIntegrations.instance.buildQrScanner(
                  onDetect: _onDetect,
                  paused: _handling || _problem != null,
                ) ??
                const SizedBox.shrink(),
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
                child: SafeArea(
                  top: false,
                  child: _problem == null
                      ? Text(
                          loc.sync_qr_scan_description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        )
                      : Semantics(
                          liveRegion: true,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _problem!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              FilledButton(
                                onPressed: () =>
                                    setState(() => _problem = null),
                                child: Text(loc.sync_qr_scan_again),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MediaTopBar(
                title: loc.sync_qr_scan_title,
                backTooltip: loc.accessibility_back_button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
