import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
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
                      // Final congratulations step - no action needed
                      return const SizedBox.shrink();
                    }

                    return FilledButton(
                      onPressed: canProceed
                          ? () async {
                              if (wizardState.currentStep ==
                                  WizardState.totalSteps - 2) {
                                // This is the background step, next is congratulations
                                // Save the group and move to congratulations
                                final success = await _saveGroup(
                                  context,
                                  controller,
                                );
                                if (success) {
                                  wizardState.nextStep();
                                }
                              } else {
                                wizardState.nextStep();
                              }
                            }
                          : null,
                      child: Text(
                        wizardState.currentStep == WizardState.totalSteps - 2
                            ? gloc.wizard_finish
                            : gloc.wizard_next,
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
    // Period (step 3) and background (step 4) are optional
    return step == 3 || step == 4;
  }

  bool _canProceedFromStep(int step, GroupFormState formState) {
    switch (step) {
      case 0: // Name step
        return formState.title.trim().isNotEmpty;
      case 1: // Participants step
        return formState.participants.isNotEmpty;
      case 2: // Categories step
        return formState.categories.isNotEmpty;
      case 3: // Period step (optional)
      case 4: // Background step (optional)
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
}
