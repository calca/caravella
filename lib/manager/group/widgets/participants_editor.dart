import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'participants_section.dart';
import 'package:caravella_core/caravella_core.dart';
import '../group_form_controller.dart';

class ParticipantsEditor extends StatelessWidget {
  const ParticipantsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    final loc = gen.AppLocalizations.of(context);
    return ParticipantsSection(
      showHeader: false,
      participants: state.participants,
      onAddParticipant: (name) =>
          state.addParticipant(ExpenseParticipant(name: name)),
      onEditParticipant: (i, name) => state.editParticipant(i, name),
      onRemoveParticipant: controller.removeParticipantIfUnused,
      // Someone who paid an expense stays: the bin says why.
      deleteBlockedReason: (i) {
        final id = state.participants[i].id;
        final paid = (state.originalGroup?.expenses ?? const <ExpenseDetails>[])
            .where((e) => e.paidBy.id == id)
            .length;
        return paid == 0 ? null : loc.cannot_delete_participant_paid(paid);
      },
    );
  }
}
