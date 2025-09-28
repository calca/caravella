import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'editable_name_list.dart';

class ParticipantsSection extends StatelessWidget {
  final List<ExpenseParticipant> participants;
  final void Function(String) onAddParticipant;
  final void Function(int, String) onEditParticipant;
  final void Function(int) onRemoveParticipant;

  const ParticipantsSection({
    super.key,
    required this.participants,
    required this.onAddParticipant,
    required this.onEditParticipant,
    required this.onRemoveParticipant,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return EditableNameList(
      title: loc.participants,
      requiredMark: true,
      description: loc.participants_description,
      items: participants.map((e) => e.name).toList(),
      addLabel: loc.add_participant,
      hintLabel: loc.participant_name,
      editTooltip: loc.edit_participant,
      deleteTooltip: loc.delete,
      saveTooltip: loc.save,
      cancelTooltip: loc.cancel,
      addTooltip: loc.add,
      duplicateError: '${loc.participant_name} ${loc.already_exists}',
      onAdd: onAddParticipant,
      onEdit: onEditParticipant,
      onDelete: onRemoveParticipant,
      itemIcon: AppIcons.participant,
    );
  }
}
