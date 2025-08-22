import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'participants_section.dart';
import '../data/group_form_state.dart';
import '../../../data/model/expense_participant.dart';

class ParticipantsEditor extends StatelessWidget {
  const ParticipantsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    return ParticipantsSection(
      participants: state.participants,
      onAddParticipant: (name) =>
          state.addParticipant(ExpenseParticipant(name: name)),
      onEditParticipant: (i, name) => state.editParticipant(i, name),
      onRemoveParticipant: (i) => state.removeParticipant(i),
    );
  }
}
