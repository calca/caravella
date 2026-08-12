import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'icon_leading_field.dart';

/// Paid-by selector: a horizontally scrolling row of participant chips,
/// ordered last-used-first, with inline add and an overflow "more" chip
/// when there are many participants. Rendered identically in the compact
/// and the extended expense form.
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

    return IconLeadingField(
      icon: Icon(AppIcons.participant),
      semanticsLabel: gloc.paid_by,
      tooltip: gloc.paid_by,
      child: ChipSelectorRow<ExpenseParticipant>(
        items: participants,
        selected: selectedParticipant,
        itemLabel: (p) => p.name,
        onSelected: onParticipantSelected,
        moreLabel: gloc.more,
        enabled: enabled,
        onAddItemInline: onAddParticipantInline,
        addItemHint: gloc.participant_name,
        addLabel: gloc.add,
        cancelLabel: gloc.cancel,
        addCategoryLabel: gloc.add_participant,
        alreadyExistsMessage: '${gloc.participant_name} ${gloc.already_exists}',
        sheetTitle: gloc.participants_label,
      ),
    );
  }
}
