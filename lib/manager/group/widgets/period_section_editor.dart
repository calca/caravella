import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'section_period.dart';
import '../data/group_form_state.dart';

class PeriodSectionEditor extends StatelessWidget {
  final Future<DateTime?> Function(bool isStart) onPickDate;
  const PeriodSectionEditor({super.key, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    return SectionPeriod(
      startDate: state.startDate,
      endDate: state.endDate,
      onPickDate: (isStart) async {
        final d = await onPickDate(isStart);
        if (d != null) {
          state.setDates(
            start: isStart ? d : state.startDate,
            end: isStart ? state.endDate : d,
          );
        }
      },
      onClearDates: () => state.clearDates(),
      description: gen.AppLocalizations.of(context).dates_description,
    );
  }
}
