import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// Where a receipt scan is: reading, nothing found, or failed.
enum ReceiptScanStatus { reading, noText, failed }

/// The receipt scan's line above the form's fields: a spinner while the
/// photo is read, then what went wrong (with × to close) if nothing could
/// be filled in. A good read leaves no line: the filled fields say it.
class ReceiptScanLine extends StatelessWidget {
  final ReceiptScanStatus status;
  final VoidCallback onClose;

  const ReceiptScanLine({
    super.key,
    required this.status,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final reading = status == ReceiptScanStatus.reading;
    final failed = status == ReceiptScanStatus.failed;
    final text = switch (status) {
      ReceiptScanStatus.reading => gloc.scanning_receipt,
      ReceiptScanStatus.noText => gloc.no_text_found,
      ReceiptScanStatus.failed => gloc.receipt_scan_error,
    };
    final color = failed ? s.error : s.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: reading
                  ? CircularProgressIndicator(strokeWidth: 2, color: s.primary)
                  : Icon(
                      failed
                          ? Icons.error_outline_rounded
                          : Icons.receipt_long_outlined,
                      size: 20,
                      color: color,
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
            if (!reading)
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: s.onSurfaceVariant,
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
