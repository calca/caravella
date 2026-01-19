import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import '../../data/group_form_state.dart';
import '../../../details/pages/expense_group_detail_page.dart';

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
                    icon: Icons.people_rounded,
                    title: gloc.wizard_completion_customize_group,
                    subtitle:
                        gloc.wizard_completion_customize_group_description,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action button
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  // Load the group and navigate to detail page
                  final group = await ExpenseGroupStorageV2.getTripById(
                    widget.groupId,
                  );
                  if (group != null && context.mounted) {
                    // Pop the wizard
                    Navigator.of(context).pop();
                    // Navigate to the group detail page
                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenseGroupDetailPage(trip: group),
                        ),
                      );
                    }
                  }
                },
                label: Text(gloc.wizard_go_to_group),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
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
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
