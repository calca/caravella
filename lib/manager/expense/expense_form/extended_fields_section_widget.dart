import 'package:flutter/material.dart';
import '../../../data/model/expense_location.dart';
import '../../../themes/form_theme.dart';
import 'date_selector_widget.dart';
import 'location_input_widget.dart';
import 'note_input_widget.dart';

/// Section hosting date, location and note fields (only when expanded or editing existing expense).
class ExtendedFieldsSectionWidget extends StatelessWidget {
  final bool show;
  final DateTime? selectedDate;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final ValueChanged<DateTime> onDateSelected;
  final ExpenseLocation? location;
  final ValueChanged<ExpenseLocation?> onLocationChanged;
  final TextEditingController noteController;
  final FocusNode noteFocus;
  final FocusNode locationFocus;
  final TextStyle? textStyle;
  final String locale;
  final Key locationFieldKey;
  final Key noteFieldKey;

  const ExtendedFieldsSectionWidget({
    super.key,
    required this.show,
    required this.selectedDate,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.onDateSelected,
    required this.location,
    required this.onLocationChanged,
    required this.noteController,
    required this.noteFocus,
    required this.locationFocus,
    required this.textStyle,
    required this.locale,
    required this.locationFieldKey,
    required this.noteFieldKey,
  });

  Widget _spacer() => const SizedBox(height: FormTheme.fieldSpacing);

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _spacer(),
        DateSelectorWidget(
          selectedDate: selectedDate,
          tripStartDate: tripStartDate,
          tripEndDate: tripEndDate,
          onDateSelected: onDateSelected,
          locale: locale,
          textStyle: textStyle,
        ),
        _spacer(),
        KeyedSubtree(
          key: locationFieldKey,
          child: LocationInputWidget(
            initialLocation: location,
            textStyle: textStyle,
            onLocationChanged: onLocationChanged,
            externalFocusNode: locationFocus,
          ),
        ),
        _spacer(),
        KeyedSubtree(
          key: noteFieldKey,
          child: NoteInputWidget(
            controller: noteController,
            textStyle: textStyle,
            focusNode: noteFocus,
          ),
        ),
      ],
    );
  }
}
