import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/date_range_formatter.dart';

class DateSelectorWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final void Function(DateTime) onDateSelected;
  final String locale;
  final bool enabled;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.locale,
    this.tripStartDate,
    this.tripEndDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final now = DateTime.now();
    final date = selectedDate;
    final isToday =
        date != null &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final dateText = date == null
        ? gloc.select_expense_date_short
        : isToday
        ? gloc.today
        : formatDate(date, Locale(locale));
    final semanticLabel = '${gloc.date}: $dateText';

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: tripStartDate ?? DateTime(2000),
        lastDate: tripEndDate ?? DateTime(2100),
        helpText: gloc.select_expense_date,
        cancelText: gloc.cancel,
        confirmText: gloc.ok,
        locale: Locale(locale),
      );
      if (picked != null) {
        onDateSelected(picked);
      }
    }

    return FormPill(
      icon: Icons.event_outlined,
      label: dateText,
      semanticsLabel: semanticLabel,
      onTap: enabled ? pickDate : null,
    );
  }
}
