import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../pages/group_creation_wizard_page.dart';

class WizardStepIndicator extends StatelessWidget {
  const WizardStepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      child: Consumer<WizardState>(
        builder: (context, wizardState, child) {
          return Column(
            children: [
              // Step progress indicator
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value:
                          (wizardState.currentStep + 1) /
                          WizardState.totalSteps,
                      backgroundColor: theme.colorScheme.outline.withAlpha(51),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStepTitle(wizardState.currentStep, gloc),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${wizardState.currentStep + 1} ${gloc.wizard_step_of} ${WizardState.totalSteps}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStepTitle(int step, gen.AppLocalizations gloc) {
    switch (step) {
      case 0:
        return gloc.wizard_step_name;
      case 1:
        return gloc.wizard_step_participants;
      case 2:
        return gloc.wizard_step_categories;
      case 3:
        return gloc.wizard_step_period;
      case 4:
        return gloc.wizard_step_background;
      case 5:
        return gloc.wizard_step_congratulations;
      default:
        return '';
    }
  }
}
