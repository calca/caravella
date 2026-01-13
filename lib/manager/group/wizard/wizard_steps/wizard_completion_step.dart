import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';

class WizardCompletionStep extends StatefulWidget {
  final String groupId;

  const WizardCompletionStep({super.key, required this.groupId});

  @override
  State<WizardCompletionStep> createState() => _WizardCompletionStepState();
}

class _WizardCompletionStepState extends State<WizardCompletionStep> {
  late final String _randomEmoji;

  static const _celebrationEmojis = ['🎉', '🎊', '🥳', '✨', '🌟', '🚀'];

  @override
  void initState() {
    super.initState();
    _randomEmoji =
        _celebrationEmojis[Random().nextInt(_celebrationEmojis.length)];
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final groupName = context.watch<GroupFormState>().title;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Celebration emoji
            Text(_randomEmoji, style: const TextStyle(fontSize: 72)),

            const SizedBox(height: 24),

            // Success title
            Text(
              gloc.wizard_success_title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Success message
            Text(
              gloc.wizard_congratulations_message(groupName),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // What's next section
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gloc.wizard_completion_what_next,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _NextStepTile(
                    icon: Icons.receipt_long_rounded,
                    title: gloc.wizard_completion_add_expenses,
                    subtitle: gloc.wizard_completion_add_expenses_description,
                  ),
                  const SizedBox(height: 8),
                  _NextStepTile(
                    icon: Icons.tune_rounded,
                    title: gloc.wizard_completion_customize_group,
                    subtitle:
                        gloc.wizard_completion_customize_group_description,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Go to group page (primary action)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      // Navigation to group page will happen automatically
                      // since the wizard returns true and the caller opens the group
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(gloc.wizard_go_to_group),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Go to settings (secondary action)
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Close wizard first
                      Navigator.of(context).pop(true);

                      // Wait a frame to ensure navigation is complete
                      await Future.delayed(const Duration(milliseconds: 100));

                      if (context.mounted) {
                        // Navigate to group settings
                        // Import the settings page and navigate
                        // This will be handled by passing a special result
                        // to indicate we want to go to settings
                        Navigator.of(context).pop('settings');
                      }
                    },
                    icon: const Icon(Icons.settings_rounded, size: 20),
                    label: Text(gloc.wizard_go_to_settings),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
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

class _NextStepTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NextStepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
