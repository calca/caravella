import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../widgets/themed_outlined_button.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etichetta per il campo data
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            gen.AppLocalizations.of(context).date,
            style: textStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ThemedOutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: tripStartDate ?? DateTime(2000),
                lastDate: tripEndDate ?? DateTime(2100),
                helpText: gen.AppLocalizations.of(context).select_expense_date,
                cancelText: gen.AppLocalizations.of(context).cancel,
                confirmText: gen.AppLocalizations.of(context).ok,
                locale: Locale(locale),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                      : gen.AppLocalizations.of(context).select_expense_date_short,
                  style: textStyle ?? Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.event,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
