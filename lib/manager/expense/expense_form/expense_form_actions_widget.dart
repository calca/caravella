import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final AppLocalizations loc;

  const ExpenseFormActionsWidget({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Text(loc.get('add_expense')),
        ),
      ],
    );
  }
}
