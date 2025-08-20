import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';

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

    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    Future<void> _pickDate() async {
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

    return IconLeadingField(
      semanticsLabel: semanticLabel,
      tooltip: gloc.date,
      icon: Icon(
        Icons.event_outlined,
        size: 22,
        color: iconColor,
      ),
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: _pickDate,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              dateText,
              style: textStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}
