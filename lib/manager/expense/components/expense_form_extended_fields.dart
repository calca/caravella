library;

import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/date_selector_widget.dart';
import '../widgets/note_input_widget.dart';
import '../widgets/attachment_input_widget.dart';
import '../location/widgets/location_input_widget.dart';
import '../pages/attachment_viewer_page.dart';
import '../state/expense_form_controller.dart';

/// The "Details" part of the expense form: date, place, attachments and
/// note as pills. A pill is dashed while its value is still to add; the
/// attachments strip and the note field appear below once there is
/// something in them (or the note pill is tapped).
class ExpenseFormExtendedFields extends StatefulWidget {
  final ExpenseFormController controller;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String locale;
  final String groupId;
  final String groupName;
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
    required this.isFormValid,
    required this.onSaveExpense,
    this.isReadOnly = false,
  });

  @override
  State<ExpenseFormExtendedFields> createState() =>
      _ExpenseFormExtendedFieldsState();
}

class _ExpenseFormExtendedFieldsState extends State<ExpenseFormExtendedFields> {
  bool _noteOpened = false;

  ExpenseFormController get _controller => widget.controller;

  void _openNote() {
    setState(() => _noteOpened = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.noteFocus.requestFocus();
    });
  }

  void _removeAttachment(int index) {
    final filePath = _controller.state.attachments[index];
    try {
      File(filePath).deleteSync();
    } catch (e) {
      // File might not exist, ignore error
    }
    _controller.removeAttachment(index);
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final state = _controller.state;
    final enabled = !widget.isReadOnly;
    final hasAttachments = state.attachments.isNotEmpty;
    final showNote = _noteOpened || _controller.noteController.text.isNotEmpty;

    final pills = <Widget>[
      DateSelectorWidget(
        selectedDate: state.date,
        tripStartDate: widget.tripStartDate,
        tripEndDate: widget.tripEndDate,
        onDateSelected: _controller.updateDate,
        locale: widget.locale,
        enabled: enabled,
      ),
      if (enabled || state.location != null)
        KeyedSubtree(
          key: _controller.locationFieldKey,
          child: LocationInputWidget(
            initialLocation: state.location,
            onLocationChanged: _controller.updateLocation,
            isRetrieving: state.isRetrievingLocation,
            onRetrievalStatusChanged: _controller.setLocationRetrieving,
            enabled: enabled,
          ),
        ),
      if (!hasAttachments && enabled)
        AttachmentInputWidget(
          asPill: true,
          groupId: widget.groupId,
          groupName: widget.groupName,
          attachments: state.attachments,
          onAttachmentAdded: _controller.addAttachment,
          onAttachmentRemoved: _removeAttachment,
          onAttachmentTapped: (path) => _openAttachmentViewer(context, path),
        ),
      if (!showNote && enabled)
        FormPill(
          icon: Icons.sticky_note_2_outlined,
          label: gloc.note,
          style: FormPillStyle.add,
          onTap: _openNote,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionLabel(gloc.expense_details_section),
        Wrap(
          spacing: AppSpacing.xs,
          // FormPill's own touch margin already spaces the rows.
          runSpacing: 0,
          children: pills,
        ),
        if (hasAttachments) ...[
          const SizedBox(height: AppSpacing.md),
          AttachmentInputWidget(
            groupId: widget.groupId,
            groupName: widget.groupName,
            attachments: state.attachments,
            onAttachmentAdded: _controller.addAttachment,
            onAttachmentRemoved: _removeAttachment,
            onAttachmentTapped: (path) => _openAttachmentViewer(context, path),
            enabled: enabled,
          ),
        ],
        if (showNote) ...[
          const SizedBox(height: AppSpacing.md),
          KeyedSubtree(
            key: _controller.noteFieldKey,
            child: NoteInputWidget(
              controller: _controller.noteController,
              focusNode: _controller.noteFocus,
              textInputAction: widget.isFormValid
                  ? TextInputAction.done
                  : TextInputAction.newline,
              onFieldSubmitted: widget.isFormValid
                  ? widget.onSaveExpense
                  : null,
              enabled: enabled,
            ),
          ),
        ],
      ],
    );
  }

  void _openAttachmentViewer(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttachmentViewerPage(
          attachments: _controller.state.attachments,
          initialIndex: _controller.state.attachments.indexOf(path),
          onDelete: _removeAttachment,
        ),
      ),
    );
  }
}
