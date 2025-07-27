import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

class DateSelectorWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final void Function(DateTime) onDateSelected;
  final AppLocalizations loc;
  final String locale;
  final TextStyle? textStyle;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.loc,
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
            loc.get('date'),
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
                helpText: loc.get('select_expense_date'),
                cancelText: loc.get('cancel'),
                confirmText: loc.get('ok'),
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
                      : loc.get('select_expense_date_short'),
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
