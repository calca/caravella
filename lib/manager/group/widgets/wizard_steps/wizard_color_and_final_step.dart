import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../background_picker.dart';

class WizardColorAndFinalStep extends StatelessWidget {
  const WizardColorAndFinalStep({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Step description
          Text(
            gloc.wizard_color_and_final_description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Color picker section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color picker
                  const BackgroundPicker(),

                  const SizedBox(height: 32),

                  // Preview section
                  Consumer<GroupFormState>(
                    builder: (context, formState, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.preview_outlined,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  gloc.wizard_preview_title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Group name
                            if (formState.title.isNotEmpty) ...[
                              _buildPreviewRow(
                                context,
                                Icons.title_outlined,
                                formState.title,
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Participants count
                            if (formState.participants.isNotEmpty) ...[
                              _buildPreviewRow(
                                context,
                                Icons.group_outlined,
                                gloc.wizard_created_participants(
                                  formState.participants.length,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Categories count
                            if (formState.categories.isNotEmpty) ...[
                              _buildPreviewRow(
                                context,
                                Icons.category_outlined,
                                gloc.wizard_created_categories(
                                  formState.categories.length,
                                ),
                              ),
                            ],

                            // Period if set
                            if (formState.startDate != null ||
                                formState.endDate != null) ...[
                              const SizedBox(height: 8),
                              _buildPreviewRow(
                                context,
                                Icons.date_range_outlined,
                                _formatPeriod(formState, context),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
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
