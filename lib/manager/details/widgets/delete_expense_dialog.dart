import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

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

    return Material3Dialog(
      title: Text(gloc.delete_expense_confirm_title),
      content: Text(gloc.delete_expense_confirm),
      actions: [
        Material3DialogActions.cancel(context, gloc.cancel),
        Material3DialogActions.destructive(
          context,
          gloc.delete,
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ],
    );
  }
}
