import 'package:flutter/material.dart';
import '../../../data/model/expense_details.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class DeleteExpenseDialog extends StatelessWidget {
  final ExpenseDetails expense;
  final VoidCallback onDelete;

  const DeleteExpenseDialog({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(gloc.delete_expense),
      content: Text(gloc.delete_expense_confirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(gloc.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
          child: Text(gloc.delete, style: TextStyle(color: colorScheme.error)),
        ),
      ],
    );
  }
}
