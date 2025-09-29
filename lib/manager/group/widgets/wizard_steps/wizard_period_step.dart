import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/group_form_state.dart';
import '../period_section_editor.dart';

class WizardPeriodStep extends StatelessWidget {
  const WizardPeriodStep({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Step description
          Text(
            gloc.wizard_period_description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // Period editor
          PeriodSectionEditor(
            onPickDate: (isStart) async => _pickDate(context, isStart),
          ),

          const Spacer(),

          // Visual hint
          Center(
            child: Icon(
              Icons.date_range_outlined,
              size: 120,
              color: theme.colorScheme.primary.withAlpha(77),
            ),
          ),

          const Spacer(),

          // Optional note
          Center(
            child: Text(
              gloc.dates_description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, bool isStart) async {
    final formState = context.read<GroupFormState>();
    final initialDate = isStart
        ? formState.startDate ?? DateTime.now()
        : formState.endDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (isStart) {
        formState.setStartDate(pickedDate);
      } else {
        formState.setEndDate(pickedDate);
      }
    }

    return pickedDate;
  }
}
