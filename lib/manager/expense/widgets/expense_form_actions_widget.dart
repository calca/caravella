import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final bool isFormValid;
  final VoidCallback? onDelete; // Shown only in edit mode
  final bool isEdit;
  final TextStyle? textStyle;
  final bool
  showExpandButton; // When true shows an expand button (only in add/compact mode)
  final VoidCallback? onExpand;
  final VoidCallback? onScanReceipt; // Scan receipt with OCR
  final bool showVoiceButton;
  final VoidCallback? onVoiceTap;

  const ExpenseFormActionsWidget({
    super.key,
    required this.onSave,
    this.isFormValid = false,
    this.onDelete,
    this.isEdit = false,
    this.textStyle,
    this.showExpandButton = false,
    this.onExpand,
    this.onScanReceipt,
    this.showVoiceButton = false,
    this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Shared style for all action buttons in the row.
    final iconButtonStyle = IconButton.styleFrom(
      backgroundColor: colorScheme.surfaceContainerHighest,
      foregroundColor: colorScheme.onSurfaceVariant,
      minimumSize: const Size(48, 48),
      padding: EdgeInsets.zero,
    );

    final leftButtons = <Widget>[];

    // Add scan receipt button (only in add mode, not edit mode)
    if (!isEdit && onScanReceipt != null) {
      leftButtons.add(
        IconButton(
          tooltip: gloc.scan_receipt,
          onPressed: onScanReceipt,
          icon: const Icon(Icons.document_scanner_outlined, size: 24),
          style: iconButtonStyle,
        ),
      );
    }

    // Mic — leftmost
    if (showVoiceButton && onVoiceTap != null) {
      leftButtons.add(
        IconButton(
          tooltip: gloc.voice_input_button,
          onPressed: onVoiceTap,
          icon: const Icon(Icons.mic_none, size: 24),
          style: iconButtonStyle,
        ),
      );
    }

    // Expand
    if (showExpandButton && onExpand != null) {
      leftButtons.add(
        IconButton(
          tooltip: gloc.expand_form_tooltip.isNotEmpty
              ? gloc.expand_form_tooltip
              : gloc.expand_form,
          onPressed: onExpand,
          icon: const Icon(Icons.arrow_circle_up_outlined, size: 24),
          style: iconButtonStyle,
        ),
      );
    }

    // Delete (edit mode)
    if (isEdit && onDelete != null) {
      leftButtons.add(
        IconButton(
          style: iconButtonStyle,
          tooltip: gloc.delete_expense,
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 24),
        ),
      );
    }

    // Intersperse spacing between left buttons
    final leftChildren = <Widget>[];
    for (var i = 0; i < leftButtons.length; i++) {
      leftChildren.add(leftButtons[i]);
      if (i != leftButtons.length - 1) {
        leftChildren.add(const SizedBox(width: 8));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...leftChildren,
        if (leftChildren.isNotEmpty) const SizedBox(width: 8),
        const Spacer(),
        // Aggiungi / Save — green filled when valid, muted when invalid
        TextButton(
          onPressed: onSave,
          style: TextButton.styleFrom(
            backgroundColor: isFormValid
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            foregroundColor: isFormValid
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isEdit ? gloc.save.toUpperCase() : gloc.add.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isFormValid
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
