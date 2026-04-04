library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/note_input_widget.dart';
import '../widgets/attachment_input_widget.dart';
import '../location/widgets/location_input_widget.dart';
import '../pages/attachment_viewer_page.dart';
import '../state/expense_form_controller.dart';

/// Builds extended form fields: date, location, attachments, notes
/// These fields are shown when fullEdit is true or form is expanded
class ExpenseFormExtendedFields extends StatelessWidget {
  final ExpenseFormController controller;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String locale;
  final String groupId;
  final String groupName;
  final bool autoLocationEnabled;
  final bool isInitialExpense;
  final bool isFormValid;
  final VoidCallback onSaveExpense;
  final bool isReadOnly;

  const ExpenseFormExtendedFields({
    super.key,
    required this.controller,
    required this.tripStartDate,
    required this.tripEndDate,
    required this.locale,
    required this.groupId,
    required this.groupName,
    required this.autoLocationEnabled,
    required this.isInitialExpense,
    required this.isFormValid,
    required this.onSaveExpense,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: FormTheme.fieldSpacing),
            DateSelectorWidget(
              selectedDate: controller.state.date,
              tripStartDate: tripStartDate,
              tripEndDate: tripEndDate,
              onDateSelected: controller.updateDate,
              locale: locale,
              textStyle: style,
              enabled: !isReadOnly,
            ),
            SizedBox(height: FormTheme.fieldSpacing),
            KeyedSubtree(
              key: controller.locationFieldKey,
              child: LocationInputWidget(
                initialLocation: controller.state.location,
                textStyle: style,
                onLocationChanged: controller.updateLocation,
                externalFocusNode: controller.locationFocus,
                autoRetrieve: !isInitialExpense && autoLocationEnabled,
                onRetrievalStatusChanged: controller.setLocationRetrieving,
                enabled: !isReadOnly,
              ),
            ),
            SizedBox(height: FormTheme.fieldSpacing),
            AttachmentInputWidget(
              groupId: groupId,
              groupName: groupName,
              attachments: controller.state.attachments,
              onAttachmentAdded: controller.addAttachment,
              onAttachmentRemoved: (index) {
                // Delete the file from storage
                final filePath = controller.state.attachments[index];
                try {
                  File(filePath).deleteSync();
                } catch (e) {
                  // File might not exist, ignore error
                }
                controller.removeAttachment(index);
              },
              onAttachmentTapped: (path) {
                _openAttachmentViewer(context, path);
              },
              enabled: !isReadOnly,
            ),
            SizedBox(height: FormTheme.fieldSpacing),
            KeyedSubtree(
              key: controller.noteFieldKey,
              child: NoteInputWidget(
                controller: controller.noteController,
                textStyle: style,
                focusNode: controller.noteFocus,
                textInputAction: isFormValid
                    ? TextInputAction.done
                    : TextInputAction.newline,
                onFieldSubmitted: isFormValid ? onSaveExpense : null,
                enabled: !isReadOnly,
              ),
            ),
          ],
        );
      },
    );
  }

  void _openAttachmentViewer(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttachmentViewerPage(
          attachments: controller.state.attachments,
          initialIndex: controller.state.attachments.indexOf(path),
          onDelete: (index) {
            // Delete the file from storage
            final filePath = controller.state.attachments[index];
            try {
              File(filePath).deleteSync();
            } catch (e) {
              // File might not exist, ignore error
            }
            controller.removeAttachment(index);
          },
        ),
      ),
    );
  }
}
