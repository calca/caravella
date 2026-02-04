import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../pages/group_creation_wizard_page.dart';

class WizardStepIndicator extends StatelessWidget {
  const WizardStepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Consumer<WizardState>(
        builder: (context, wizardState, child) {
          return Row(
            children: [
              // Step dots indicator
              Row(
                children: List.generate(wizardState.totalSteps, (index) {
                  final isCompleted = index < wizardState.currentStep;
                  final isCurrent = index == wizardState.currentStep;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(
                      horizontal: index < wizardState.totalSteps - 1 ? 4 : 0,
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
                        if (index < wizardState.totalSteps - 1)
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

              if (wizardState.totalSteps > 1) ...[
                const Spacer(),
                Text(
                  '${wizardState.currentStep + 1}/${wizardState.totalSteps}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
