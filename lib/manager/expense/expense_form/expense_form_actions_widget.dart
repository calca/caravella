import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final AppLocalizations loc;
  final bool isEdit;

  const ExpenseFormActionsWidget({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.loc,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final saveLabel =
        isEdit ? loc.get('save_change_expense') : loc.get('add_expense');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedOutlinedButton(
          onPressed: onCancel,
          child: Text(loc.get('cancel')),
        ),
        const SizedBox(height: 8),
        ThemedOutlinedButton(
          onPressed: onSave,
          isPrimary: true,
          child: Text(saveLabel),
        ),
      ],
    );
  }
}
