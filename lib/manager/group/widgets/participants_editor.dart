import 'package:flutter/material.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'participants_section.dart';
import 'package:caravella_core/caravella_core.dart';
import '../group_form_controller.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

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
        final removed = await controller.removeParticipantIfUnused(i);
        if (!removed) {
          AppToast.show(
            context,
            loc.cannot_delete_assigned_participant,
            type: ToastType.info,
          );
        }
      },
    );
  }
}
