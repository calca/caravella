import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// Paid-by selector: a "Paid by" label above participant pills with their
/// initials, ordered last-used-first, with inline add and an overflow
/// "more" pill when there are many participants. Rendered identically in
/// the compact and the extended expense form.
class ParticipantSelectorWidget extends StatelessWidget {
  final List<ExpenseParticipant> participants;
  final ExpenseParticipant? selectedParticipant;
  final ValueChanged<ExpenseParticipant> onParticipantSelected;
  final Future<void> Function(String)? onAddParticipantInline;
  final bool enabled;

  const ParticipantSelectorWidget({
    super.key,
    required this.participants,
    required this.selectedParticipant,
    required this.onParticipantSelected,
    this.onAddParticipantInline,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionLabel(gloc.paid_by),
        ChipSelectorRow<ExpenseParticipant>(
          items: participants,
          selected: selectedParticipant,
          itemLabel: (p) => p.name,
          itemLeading: (p) =>
              ParticipantAvatar(participant: p, size: 28, decorative: true),
          onSelected: onParticipantSelected,
          enabled: enabled,
          onAddItemInline: onAddParticipantInline,
          addItemHint: gloc.participant_name,
          addLabel: gloc.add,
          cancelLabel: gloc.cancel,
          addCategoryLabel: gloc.add_participant,
          alreadyExistsMessage:
              '${gloc.participant_name} ${gloc.already_exists}',
          sheetTitle: gloc.participants_label,
        ),
      ],
    );
  }
}
