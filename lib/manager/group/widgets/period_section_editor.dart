import 'package:flutter/material.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'section_period.dart';

class PeriodSectionEditor extends StatelessWidget {
  final VoidCallback onClearDates;
  final String? errorText;
  const PeriodSectionEditor({
    super.key,
    required this.onClearDates,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    return SectionPeriod(
      startDate: state.startDate,
      endDate: state.endDate,
      onClearDates: onClearDates,
      description: gen.AppLocalizations.of(context).dates_description,
      errorText: errorText,
      isEndDateEnabled: state.startDate != null,
      onDateRangeChanged: (startDate, endDate) {
        state.setDates(start: startDate, end: endDate);
      },
    );
  }
}
