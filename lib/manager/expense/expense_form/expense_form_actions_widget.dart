import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback? onSave;
  final AppLocalizations loc;
  final bool isEdit;
  final TextStyle? textStyle; // Initialize textStyle property

  const ExpenseFormActionsWidget({
    super.key,
    required this.onSave,
    required this.loc,
    this.isEdit = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isEdit ? Icons.save_rounded : Icons.check_rounded;
    final label = isEdit ? loc.get('save_change_expense') : loc.get('add_expense');
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton.filled(
        onPressed: onSave,
        tooltip: label,
        icon: Icon(icon, size: 24),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
