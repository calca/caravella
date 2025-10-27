import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'section_period.dart';

class PeriodSectionEditor extends StatelessWidget {
  final Future<DateTime?> Function(bool isStart) onPickDate;
  final VoidCallback onClearDates;
  final String? errorText;
  const PeriodSectionEditor({
    super.key,
    required this.onPickDate,
    required this.onClearDates,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    return SectionPeriod(
      startDate: state.startDate,
      endDate: state.endDate,
      onPickDate: (isStart) {
        onPickDate(isStart);
      },
      onClearDates: onClearDates,
      description: gen.AppLocalizations.of(context).dates_description,
      errorText: errorText,
      isEndDateEnabled: state.startDate != null,
      // New callback for date range changes
      onDateRangeChanged: (startDate, endDate) {
        state.setDates(start: startDate, end: endDate);
      },
    );
  }
}
