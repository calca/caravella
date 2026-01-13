import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../../widgets/participants_editor.dart';

class WizardParticipantsStep extends StatelessWidget {
  const WizardParticipantsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Step description
          Text(
            gloc.wizard_participants_description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // Participants editor
          const Expanded(child: ParticipantsEditor()),

          const SizedBox(height: 16),

          // Error message
          Consumer<GroupFormState>(
            builder: (context, state, child) {
              return state.participants.isEmpty
                  ? Text(
                      '* ${gloc.enter_participant}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
