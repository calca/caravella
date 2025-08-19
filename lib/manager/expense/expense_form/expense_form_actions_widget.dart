import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

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
    final saveLabel =
        isEdit ? loc.get('save_change_expense') : loc.get('add_expense');
    return ThemedOutlinedButton(
      onPressed: onSave,
      isPrimary: true,
      child: Text(saveLabel, style: textStyle),
    );
  }
}
