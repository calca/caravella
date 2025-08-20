import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final bool isEdit;
  final TextStyle? textStyle; // Initialize textStyle property

  const ExpenseFormActionsWidget({
    super.key,
    required this.onSave,
    this.isEdit = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isEdit ? Icons.save_rounded : Icons.check_rounded;
    // Use existing save_change_expense for edit; generic label for add
    final gloc = gen.AppLocalizations.of(context);
    final label = isEdit ? gloc.save_change_expense : 'Save';
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton.filled(
        onPressed: onSave,
        tooltip: label,
        icon: Icon(icon, size: 24),
        style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
      ),
    );
  }
}
