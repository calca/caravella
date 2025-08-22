import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onDelete; // Shown only in edit mode
  final bool isEdit;
  final TextStyle? textStyle;

  const ExpenseFormActionsWidget({
    super.key,
    required this.onSave,
    this.onDelete,
    this.isEdit = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final saveLabel = gloc.save_change_expense;
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEdit && onDelete != null)
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
                backgroundColor: colorScheme.surfaceContainer,
              ),
              tooltip: gloc.delete_expense, // Assume localization key exists
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
                size: 22,
              ),
            ),
          if (isEdit && onDelete != null) const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSave,
            tooltip: saveLabel,
            icon: const Icon(Icons.send_outlined, size: 24),
            style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
          ),
        ],
      ),
    );
  }
}
