import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'inline_select_field.dart';
import '../../../themes/form_theme.dart';

class DateSelectorWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final void Function(DateTime) onDateSelected;
  final String locale;
  final TextStyle? textStyle;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.locale,
    this.tripStartDate,
    this.tripEndDate,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Icona a sinistra, rimosso titolo testuale sopra
    final gloc = gen.AppLocalizations.of(context);
    final dateText = selectedDate != null
        ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
        : gloc.select_expense_date_short;
    final semanticLabel = '${gloc.date}: $dateText';

    // icon color now handled by InlineSelectField's icon theme

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

    return InlineSelectField(
      icon: Icons.event_outlined,
      label: dateText,
      onTap: pickDate,
      enabled: true,
      semanticsLabel: semanticLabel,
      textStyle: textStyle ?? FormTheme.getSelectTextStyle(context),
    );
  }
}
