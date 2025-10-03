import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../models/qr_key_exchange_payload.dart';

/// Widget to display a QR code for sharing group encryption key
class QrDisplayWidget extends StatelessWidget {
  final QrKeyExchangePayload payload;
  final VoidCallback? onClose;

  const QrDisplayWidget({
    super.key,
    required this.payload,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remainingSeconds = payload.expirationSeconds -
        DateTime.now().difference(payload.timestamp).inSeconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.share_group_qr ?? 'Share Group QR'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gloc.scan_qr_to_join ?? 'Scan this QR code to join the group',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: payload.toJsonString(),
                  version: QrVersions.auto,
                  size: 300,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
              const SizedBox(height: 24),
              if (remainingSeconds > 0) ...[
                Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  '${gloc.expires_in ?? "Expires in"} ${_formatDuration(remainingSeconds)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  gloc.qr_expired ?? 'QR code expired',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gloc.security_info ?? 'Security Information',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        gloc.qr_security_message ??
                            'This QR code contains an encrypted group key. '
                                'Only scan QR codes from trusted sources. '
                                'The QR code will expire automatically.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}
