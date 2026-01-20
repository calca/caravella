import 'package:caravella_core/model/expense_group.dart';
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
            // Hide navigation bar on completion step
            if (wizardState.currentStep == wizardState.totalSteps - 1) {
              return const SizedBox.shrink();
            }

            return Row(
              children: [
                // Previous button
                if (wizardState.currentStep > 0) ...[
                  TextButton.icon(
                    onPressed: wizardState.previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    label: Text(gloc.wizard_previous),
                    style: TextButton.styleFrom(
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
                if (_isOptionalStep(wizardState.currentStep, wizardState)) ...[
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
                    final isSecondToLastStep =
                        wizardState.currentStep == wizardState.totalSteps - 2;
                    final canProceed = _canProceedFromStep(
                      wizardState.currentStep,
                      formState,
                      wizardState,
                    );

                    if (isSecondToLastStep) {
                      // Second to last step: save and go to completion
                      return FilledButton(
                        onPressed: canProceed
                            ? () async {
                                // Close keyboard before proceeding
                                FocusScope.of(context).unfocus();
                                final group = await _saveGroup(
                                  context,
                                  controller,
                                  wizardState,
                                );
                                if (group != null && context.mounted) {
                                  wizardState.setSavedGroupId(group.id);
                                  wizardState.nextStep();
                                }
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(gloc.wizard_finish),
                      );
                    }

                    return FilledButton.icon(
                      onPressed: canProceed ? wizardState.nextStep : null,
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

  bool _isOptionalStep(int step, WizardState wizardState) {
    // User name step (step 0) is optional if it's included
    return wizardState.includeUserNameStep && step == 0;
  }

  bool _canProceedFromStep(
    int step,
    GroupFormState formState,
    WizardState wizardState,
  ) {
    if (wizardState.includeUserNameStep) {
      // With user name step: 0=name, 1=type&name, 2=completion
      switch (step) {
        case 0: // User name step (optional)
          return true;
        case 1: // Type and name step (only name is required)
          return formState.title.trim().isNotEmpty;
        default:
          return true;
      }
    } else {
      // Without user name step: 0=type&name, 1=completion
      switch (step) {
        case 0: // Type and name step (only name is required)
          return formState.title.trim().isNotEmpty;
        default:
          return true;
      }
    }
  }

  Future<ExpenseGroup?> _saveGroup(
    BuildContext context,
    GroupFormController controller,
    WizardState wizardState,
  ) async {
    try {
      final groupId = await controller.save();
      return groupId;
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
      return null;
    }
  }
}
