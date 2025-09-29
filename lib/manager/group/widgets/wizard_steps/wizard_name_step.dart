import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../group_title_field.dart';

class WizardNameStep extends StatelessWidget {
  const WizardNameStep({super.key});

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
            gloc.wizard_name_description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Group name input
          const GroupTitleField(),
          
          const SizedBox(height: 16),
          
          // Error message
          Consumer<GroupFormState>(
            builder: (context, state, child) {
              return state.title.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '* ${gloc.enter_title}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          
          const Spacer(),
          
          // Visual hint
          Center(
            child: Icon(
              Icons.title_outlined,
              size: 120,
              color: theme.colorScheme.primary.withAlpha(77),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}