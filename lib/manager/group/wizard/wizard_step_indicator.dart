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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<WizardState>(
        builder: (context, wizardState, child) {
          final progress =
              (wizardState.currentStep + 1) / WizardState.totalSteps;

          return Column(
            children: [
              // Step dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(WizardState.totalSteps, (index) {
                  final isCompleted = index < wizardState.currentStep;
                  final isCurrent = index == wizardState.currentStep;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(
                      horizontal: index < WizardState.totalSteps - 1 ? 4 : 0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isCurrent ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (index < WizardState.totalSteps - 1)
                          Container(
                            width: 24,
                            height: 2,
                            color: isCompleted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Step info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStepTitle(wizardState.currentStep, gloc),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gloc.wizard_step_of.split(' ')[0]} ${wizardState.currentStep + 1} ${gloc.wizard_step_of} ${WizardState.totalSteps}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
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
        return gloc.wizard_step_user_name;
      case 1:
        return gloc.wizard_step_type_and_name;
      default:
        return '';
    }
  }
}
