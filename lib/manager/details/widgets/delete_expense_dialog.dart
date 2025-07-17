import 'package:flutter/material.dart';
import '../../../data/expense_details.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';

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
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(loc.get('delete_expense')),
      content: Text(loc.get('delete_expense_confirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.get('cancel')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
          child: Text(
            loc.get('delete'),
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}
