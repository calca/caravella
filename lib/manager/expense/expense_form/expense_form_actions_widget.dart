import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onDelete; // Shown only in edit mode
  final bool isEdit;
  final TextStyle? textStyle;
  final bool
  showExpandButton; // When true shows an expand button (only in add/compact mode)
  final VoidCallback? onExpand;

  const ExpenseFormActionsWidget({
    super.key,
    required this.onSave,
    this.onDelete,
    this.isEdit = false,
    this.textStyle,
    this.showExpandButton = false,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final saveLabel = gloc.save_change_expense;
    final colorScheme = Theme.of(context).colorScheme;
    final leftButtons = <Widget>[];
    if (showExpandButton && onExpand != null) {
      leftButtons.add(
        IconButton.outlined(
          tooltip: gloc.expand_form_tooltip.isNotEmpty
              ? gloc.expand_form_tooltip
              : gloc.expand_form,
          onPressed: onExpand,
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.unfold_more_outlined, size: 24),
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
          icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 22),
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
