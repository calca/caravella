import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onDelete; // Shown only in edit mode
  final bool isEdit;
  final TextStyle? textStyle;
  final bool
  showExpandButton; // When true shows an expand button (only in add/compact mode)
  final VoidCallback? onExpand;
  final VoidCallback? onScanReceipt; // New: scan receipt with OCR

  const ExpenseFormActionsWidget({
    super.key,
    required this.onSave,
    this.onDelete,
    this.isEdit = false,
    this.textStyle,
    this.showExpandButton = false,
    this.onExpand,
    this.onScanReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final saveLabel = gloc.save_change_expense;
    final colorScheme = Theme.of(context).colorScheme;
    final leftButtons = <Widget>[];
    
    // Add scan receipt button (only in add mode, not edit mode)
    if (!isEdit && onScanReceipt != null) {
      leftButtons.add(
        IconButton(
          tooltip: gloc.scan_receipt,
          onPressed: onScanReceipt,
          icon: const Icon(Icons.document_scanner_outlined, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }
    
    if (showExpandButton && onExpand != null) {
      leftButtons.add(
        IconButton(
          tooltip: gloc.expand_form_tooltip.isNotEmpty
              ? gloc.expand_form_tooltip
              : gloc.expand_form,
          onPressed: onExpand,
          icon: const Icon(Icons.arrow_circle_up_outlined, size: 24),
          style: IconButton.styleFrom(
            // Ensures transparent background while keeping minimum hit area
            backgroundColor: Colors.transparent,
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }
    if (isEdit && onDelete != null) {
      leftButtons.add(
        IconButton.filledTonal(
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.zero,
            backgroundColor: colorScheme.surfaceContainer,
          ),
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
        leftChildren.add(const SizedBox(width: 12));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...leftChildren,
        if (leftChildren.isNotEmpty) const SizedBox(width: 12),
        const Spacer(),
        IconButton.filled(
          onPressed: onSave,
          tooltip: saveLabel,
          icon: const Icon(Icons.send_outlined, size: 24),
          style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
        ),
      ],
    );
  }
}
