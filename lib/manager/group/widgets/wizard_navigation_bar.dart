import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../pages/group_creation_wizard_page.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';

class WizardNavigationBar extends StatelessWidget {
  const WizardNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Consumer<WizardState>(
          builder: (context, wizardState, child) {
            return Row(
              children: [
                // Previous button
                if (wizardState.currentStep > 0) ...[
                  TextButton(
                    onPressed: wizardState.previousStep,
                    child: Text(gloc.wizard_previous),
                  ),
                  const SizedBox(width: 16),
                ],

                const Spacer(),

                // Skip button for optional steps (period, background)
                if (_isOptionalStep(wizardState.currentStep)) ...[
                  TextButton(
                    onPressed: wizardState.nextStep,
                    child: Text(gloc.wizard_skip),
                  ),
                  const SizedBox(width: 16),
                ],

                // Next/Finish button
                Consumer2<GroupFormState, GroupFormController>(
                  builder: (context, formState, controller, child) {
                    final isLastStep =
                        wizardState.currentStep == WizardState.totalSteps - 1;
                    final canProceed = _canProceedFromStep(
                      wizardState.currentStep,
                      formState,
                    );

                    if (isLastStep) {
                      // Final step - show create button that saves and shows success
                      return FilledButton.icon(
                        onPressed: canProceed
                            ? () async {
                                final success = await _saveGroup(
                                  context,
                                  controller,
                                );
                                if (success && context.mounted) {
                                  // Show success dialog
                                  await _showSuccessDialog(context, formState.title);
                                  if (context.mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              }
                            : null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(gloc.wizard_finish),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      );
                    }

                    return FilledButton(
                      onPressed: canProceed ? wizardState.nextStep : null,
                      child: Text(gloc.wizard_next),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isOptionalStep(int step) {
    // Period (step 3) is optional, step 0 (user name) is also optional
    return step == 0 || step == 3;
  }

  bool _canProceedFromStep(int step, GroupFormState formState) {
    switch (step) {
      case 0: // User name step (optional)
        return true;
      case 1: // Group name step (required)
        return formState.title.trim().isNotEmpty;
      case 2: // Participants and categories step (both required)
        return formState.participants.isNotEmpty && formState.categories.isNotEmpty;
      case 3: // Period step (optional)
        return true;
      case 4: // Color and final step (all set, ready to create)
        return true;
      default:
        return true;
    }
  }

  Future<bool> _saveGroup(
    BuildContext context,
    GroupFormController controller,
  ) async {
    try {
      await controller.save();
      return true;
    } catch (e) {
      if (context.mounted) {
        final gloc = gen.AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(gloc.error_saving_group(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, String groupName) async {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Material3Dialog(
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.celebration_outlined,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(gloc.wizard_success_title),
        content: Text(gloc.wizard_congratulations_message(groupName)),
        actions: [
          Material3DialogActions.primary(
            ctx,
            gloc.wizard_go_to_group,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
