import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

class ExpenseFormActionsWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final AppLocalizations loc;
  final String? errorMessage;

  const ExpenseFormActionsWidget({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.loc,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Messaggio di errore se presente
        if (errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
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
