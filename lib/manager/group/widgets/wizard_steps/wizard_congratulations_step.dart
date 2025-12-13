import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';

class WizardCongratulationsStep extends StatelessWidget {
  const WizardCongratulationsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Consumer<GroupFormState>(
        builder: (context, formState, child) {
          return Column(
            children: [
              const SizedBox(height: 40),

              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Congratulations message
              Text(
                gloc.wizard_congratulations_message(formState.title),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Group summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gloc.wizard_group_summary,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Group name
                    _buildSummaryRow(
                      context,
                      Icons.title_outlined,
                      formState.title,
                    ),

                    const SizedBox(height: 8),

                    // Participants count
                    _buildSummaryRow(
                      context,
                      Icons.group_outlined,
                      gloc.wizard_created_participants(
                        formState.participants.length,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Categories count
                    _buildSummaryRow(
                      context,
                      Icons.category_outlined,
                      gloc.wizard_created_categories(
                        formState.categories.length,
                      ),
                    ),

                    // Period if set
                    if (formState.startDate != null ||
                        formState.endDate != null) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        context,
                        Icons.date_range_outlined,
                        _formatPeriod(formState, context),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Done button
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.check),
                label: Text(gloc.ok),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  String _formatPeriod(GroupFormState formState, BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    if (formState.startDate != null && formState.endDate != null) {
      return '${gloc.start_date_optional}: ${_formatDate(formState.startDate!)} - ${gloc.end_date_optional}: ${_formatDate(formState.endDate!)}';
    } else if (formState.startDate != null) {
      return '${gloc.start_date_optional}: ${_formatDate(formState.startDate!)}';
    } else if (formState.endDate != null) {
      return '${gloc.end_date_optional}: ${_formatDate(formState.endDate!)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
