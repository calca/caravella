import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'participants_section.dart';
import '../data/group_form_state.dart';
import '../../../data/model/expense_participant.dart';
import '../group_form_controller.dart';
import '../../../widgets/app_toast.dart';

class ParticipantsEditor extends StatelessWidget {
  const ParticipantsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    return ParticipantsSection(
      participants: state.participants,
      onAddParticipant: (name) =>
          state.addParticipant(ExpenseParticipant(name: name)),
      onEditParticipant: (i, name) => state.editParticipant(i, name),
      onRemoveParticipant: (i) async {
        final loc = gen.AppLocalizations.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final removed = await controller.removeParticipantIfUnused(i);
        if (!removed) {
          AppToast.showFromMessenger(
            messenger,
            loc.cannot_delete_assigned_participant,
            type: ToastType.info,
          );
        }
      },
    );
  }
}
