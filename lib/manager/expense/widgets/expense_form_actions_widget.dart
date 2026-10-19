import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final bool isFormValid;
  final VoidCallback? onDelete; // Shown only in edit mode
  final bool isEdit;
  final TextStyle? textStyle;
  final bool
  showExpandButton; // When true shows an expand button (only in add/compact mode)
  final VoidCallback? onExpand;
  final VoidCallback?
  onScanReceipt; // Scan receipt with OCR — tap opens the camera directly
  final VoidCallback?
  onScanReceiptFromGallery; // Long-press (or the "from gallery" custom action) picks an existing photo instead
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
    this.onScanReceiptFromGallery,
    this.showVoiceButton = false,
    this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Shared style for the round buttons left of Save: raised, monochrome.
    final iconButtonStyle = IconButton.styleFrom(
      backgroundColor: colorScheme.raisedSurface,
      foregroundColor: colorScheme.onSurface,
      side: BorderSide(color: CardOutline.colorFor(colorScheme.brightness)),
      minimumSize: const Size(52, 52),
      padding: EdgeInsets.zero,
    );

    final leftButtons = <Widget>[];

    // Mic — leftmost
    if (showVoiceButton && onVoiceTap != null) {
      leftButtons.add(
        IconButton(
          tooltip: gloc.voice_input_button,
          onPressed: onVoiceTap,
          icon: const Icon(Icons.mic_none_rounded, size: 24),
          style: iconButtonStyle,
        ),
      );
    }

    // Add scan receipt button (only in add mode, not edit mode).
    // Tap opens the camera directly (the common case, right after paying);
    // long-press — or the equivalent screen-reader custom action — picks an
    // existing photo instead, without going through an extra chooser sheet.
    if (!isEdit && onScanReceipt != null) {
      final scanFromGallery = onScanReceiptFromGallery;
      leftButtons.add(
        Semantics(
          button: true,
          label: gloc.scan_receipt,
          customSemanticsActions: scanFromGallery != null
              ? {
                  CustomSemanticsAction(label: gloc.from_gallery):
                      scanFromGallery,
                }
              : const {},
          child: Tooltip(
            message: gloc.scan_receipt,
            child: Material(
              color: colorScheme.raisedSurface,
              shape: CircleBorder(
                side: BorderSide(
                  color: CardOutline.colorFor(colorScheme.brightness),
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onScanReceipt,
                onLongPress: onScanReceiptFromGallery,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(
                    Icons.document_scanner_outlined,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...leftChildren,
        if (leftChildren.isNotEmpty) const SizedBox(width: 12),
        // Add / Save — filled when valid, muted when invalid
        Expanded(
          child: FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor: colorScheme.onSurfaceVariant,
              elevation: 0,
              minimumSize: const Size(52, 52),
              shape: const StadiumBorder(),
            ),
            child: Text(
              isEdit ? gloc.save : gloc.add_expense_button,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isFormValid
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
