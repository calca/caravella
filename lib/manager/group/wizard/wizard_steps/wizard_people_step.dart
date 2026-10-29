import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data/group_form_state.dart';
import '../../pages/group_creation_wizard_page.dart';

/// Who shares the expenses: the user first ("Gigi (you)"), then the people
/// added by name, each a pill with their initials; tap one to remove it.
class WizardPeopleStep extends StatefulWidget {
  const WizardPeopleStep({super.key});

  @override
  State<WizardPeopleStep> createState() => _WizardPeopleStepState();
}

class _WizardPeopleStepState extends State<WizardPeopleStep> {
  /// Whether the name field is open (after "Add participant").
  bool _adding = false;

  /// Adds [name] unless someone already has it; the field stays open for
  /// the next one.
  bool _add(GroupFormState state, String name, String duplicateMessage) {
    final exists = state.participants.any(
      (p) => p.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      AppToast.show(context, duplicateMessage, type: ToastType.info);
      return false;
    }
    state.addParticipant(ExpenseParticipant(name: name));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final state = context.watch<GroupFormState>();
    final people = state.participants;

    // Initials in a neutral circle, like the settings rows' icons.
    Widget avatar(String name) => CircleAvatar(
      radius: 13,
      backgroundColor: s.onSurface.withValues(alpha: 0.06),
      child: Text(
        nameInitials(name),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: s.onSurface,
        ),
      ),
    );

    return WizardStepLayout(
      eyebrow: state.title.trim().isEmpty
          ? gloc.wizard_group_creation_title
          : state.title.trim(),
      title: gloc.wizard_participants_section_title,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final (i, p) in people.indexed)
              i == 0
                  ? FormPill(
                      leading: avatar(p.name),
                      // "Me" stays "Me"; a real name gets "(you)".
                      label: p.name == gloc.default_participant_me
                          ? p.name
                          : gloc.wizard_people_you(p.name),
                      // Not removable, but not a disabled choice either.
                      inert: true,
                    )
                  : FormPill(
                      leading: avatar(p.name),
                      label: p.name,
                      trailingIcon: Icons.close_rounded,
                      semanticsLabel: gloc.wizard_people_remove(p.name),
                      tooltip: gloc.wizard_people_remove(p.name),
                      onTap: () => state.removeParticipant(i),
                    ),
          ],
        ),
        const SizedBox(height: 16),
        // The same add flow as the pickers and the group's participants:
        // a dashed pill that opens the name field.
        if (_adding)
          InlineEntryField(
            hintText: gloc.wizard_people_add_hint,
            commitTooltip: gloc.add,
            cancelTooltip: gloc.cancel,
            textCapitalization: TextCapitalization.words,
            keepOpen: true,
            onCommit: (name) => _add(
              state,
              name,
              '${gloc.participant_name} ${gloc.already_exists}',
            ),
            onCancel: () => setState(() => _adding = false),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: FormPill(
              icon: Icons.add_rounded,
              label: gloc.add_participant,
              style: FormPillStyle.add,
              onTap: () => setState(() => _adding = true),
            ),
          ),
        const SizedBox(height: 16),
        WizardNote(gloc.wizard_participants_section_hint),
      ],
    );
  }
}
