import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../../widgets/group_title_field.dart';
import '../../widgets/group_type_selector.dart';

class WizardTypeAndNameStep extends StatelessWidget {
  const WizardTypeAndNameStep({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Friendly emoji icon
            Text(
              '📁',
              style: const TextStyle(fontSize: 72),
            ),

            const SizedBox(height: 24),

            // Step description
            Text(
              gloc.wizard_type_and_name_description,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Compact content container
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Group type selector (already compact)
                  const GroupTypeSelector(),

                  const SizedBox(height: 20),

                  // Group name input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.label_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              gloc.wizard_name_description,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const GroupTitleField(),
                      // Error message
                      Consumer<GroupFormState>(
                        builder: (context, state, child) {
                          return state.title.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        gloc.enter_title,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
