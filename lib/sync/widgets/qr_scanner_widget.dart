import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../models/qr_key_exchange_payload.dart';
import '../../services/qr_generation_service.dart';
import '../../../data/services/logger_service.dart';
import '../../../widgets/toast.dart';

/// Widget to scan QR codes for joining groups
class QrScannerWidget extends StatefulWidget {
  final Function(String groupId) onGroupJoined;

  const QrScannerWidget({
    super.key,
    required this.onGroupJoined,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final _qrService = QrGenerationService();
  final _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      final gloc = gen.AppLocalizations.of(context);
      final qrData = barcode.rawValue!;

      // Parse QR payload
      final payload = QrKeyExchangePayload.fromJsonString(qrData);

      // Check expiration
      if (payload.isExpired) {
        if (mounted) {
          AppToast.show(
            context,
            gloc.qr_expired ?? 'QR code has expired',
            type: ToastType.error,
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Process the scanned QR
      final groupId = await _qrService.processScannedQr(payload);

      if (groupId == null) {
        if (mounted) {
          AppToast.show(
            context,
            gloc.qr_processing_error ?? 'Failed to process QR code',
            type: ToastType.error,
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Success!
      LoggerService.info('Successfully joined group: $groupId');
      if (mounted) {
        AppToast.show(
          context,
          gloc.group_joined_successfully ?? 'Group joined successfully',
          type: ToastType.success,
        );
        widget.onGroupJoined(groupId);
        Navigator.of(context).pop();
      }
    } catch (e) {
      LoggerService.error('Failed to process QR code: $e');
      if (mounted) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.show(
          context,
          gloc.invalid_qr_code ?? 'Invalid QR code',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.scan_qr_code ?? 'Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay with scanning frame
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  gloc.scan_qr_instructions ??
                      'Position the QR code within the frame to scan',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          gloc.processing ?? 'Processing...',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
