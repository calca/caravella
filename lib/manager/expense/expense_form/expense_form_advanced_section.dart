import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../themes/form_theme.dart';
import 'date_selector_widget.dart';
import 'location_input_widget.dart';
import 'note_input_widget.dart';
import 'expense_form_state.dart';

/// Advanced section of the expense form containing date, location, and note fields
class ExpenseFormAdvancedSection extends StatelessWidget {
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String locale;
  final TextStyle? textStyle;
  final GlobalKey? locationFieldKey;
  final GlobalKey? noteFieldKey;
  
  const ExpenseFormAdvancedSection({
    super.key,
    this.tripStartDate,
    this.tripEndDate,
    required this.locale,
    this.textStyle,
    this.locationFieldKey,
    this.noteFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseFormState>(
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _spacer(),
            DateSelectorWidget(
              selectedDate: state.date,
              tripStartDate: tripStartDate,
              tripEndDate: tripEndDate,
              onDateSelected: (picked) => state.setDate(picked),
              locale: locale,
              textStyle: textStyle,
            ),
            _spacer(),
            KeyedSubtree(
              key: locationFieldKey,
              child: LocationInputWidget(
                initialLocation: state.location,
                textStyle: textStyle,
                onLocationChanged: (location) => state.setLocation(location),
                externalFocusNode: state.locationFocus,
              ),
            ),
            _spacer(),
            KeyedSubtree(
              key: noteFieldKey,
              child: NoteInputWidget(
                controller: state.noteController,
                textStyle: textStyle,
                focusNode: state.noteFocus,
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _spacer() => const SizedBox(height: FormTheme.fieldSpacing);
}