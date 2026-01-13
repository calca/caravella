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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Consumer<WizardState>(
          builder: (context, wizardState, child) {
            return Row(
              children: [
                // Previous button
                if (wizardState.currentStep > 0) ...[
                  OutlinedButton.icon(
                    onPressed: wizardState.previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    label: Text(gloc.wizard_previous),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                const Spacer(),

                // Skip button for optional steps
                if (_isOptionalStep(wizardState.currentStep)) ...[
                  TextButton(
                    onPressed: wizardState.nextStep,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(gloc.wizard_skip),
                  ),
                  const SizedBox(width: 12),
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
                      return FilledButton.icon(
                        onPressed: canProceed
                            ? () async {
                                final success = await _saveGroup(
                                  context,
                                  controller,
                                );
                                if (success && context.mounted) {
                                  await _showSuccessDialog(
                                    context,
                                    formState.title,
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              }
                            : null,
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: Text(gloc.wizard_finish),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }

                    return FilledButton.icon(
                      onPressed: canProceed ? wizardState.nextStep : null,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: Text(gloc.wizard_next),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
    // User name (step 0) is optional
    return step == 0;
  }

  bool _canProceedFromStep(int step, GroupFormState formState) {
    switch (step) {
      case 0: // User name step (optional)
        return true;
      case 1: // Type and name step (only name is required)
        return formState.title.trim().isNotEmpty;
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

  Future<void> _showSuccessDialog(
    BuildContext context,
    String groupName,
  ) async {
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
