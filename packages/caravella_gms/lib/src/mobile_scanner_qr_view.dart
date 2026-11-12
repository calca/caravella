import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Live camera QR scanner backed by `mobile_scanner` (ML Kit barcode
/// scanning). Reports every decoded value through [onDetect] and stops the
/// camera once [paused] becomes true.
class MobileScannerQrView extends StatefulWidget {
  final ValueChanged<String> onDetect;
  final bool paused;

  /// Called once when the camera permission is refused.
  final VoidCallback? onCameraDenied;

  const MobileScannerQrView({
    super.key,
    required this.onDetect,
    this.paused = false,
    this.onCameraDenied,
  });

  @override
  State<MobileScannerQrView> createState() => _MobileScannerQrViewState();
}

class _MobileScannerQrViewState extends State<MobileScannerQrView> {
  final MobileScannerController _controller = MobileScannerController();
  bool _reportedDenied = false;

  @override
  void didUpdateWidget(MobileScannerQrView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused && !oldWidget.paused) _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.paused) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null) widget.onDetect(raw);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: _onDetect,
      errorBuilder: (context, error) {
        if (error.errorCode == MobileScannerErrorCode.permissionDenied &&
            !_reportedDenied) {
          _reportedDenied = true;
          // Not during build: the page answers with a dialog.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onCameraDenied?.call(),
          );
        }
        // The page around it says what's wrong and what to do.
        return const ColoredBox(color: Colors.black);
      },
    );
  }
}
