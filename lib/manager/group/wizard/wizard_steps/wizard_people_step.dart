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
  final _name = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add(GroupFormState state) {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final exists = state.participants.any(
      (p) => p.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (!exists) state.addParticipant(ExpenseParticipant(name: name));
    _name.clear();
    // Ready for the next name.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final state = context.watch<GroupFormState>();
    final people = state.participants;

    Widget avatar(String name, {required bool selected}) => CircleAvatar(
      radius: 13,
      backgroundColor: selected
          ? s.onPrimary.withValues(alpha: 0.2)
          : s.surfaceContainerHighest,
      child: Text(
        nameInitials(name),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: selected ? s.onPrimary : s.onSurface,
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
                      leading: avatar(p.name, selected: true),
                      // "Me" stays "Me"; a real name gets "(you)".
                      label: p.name == gloc.default_participant_me
                          ? p.name
                          : gloc.wizard_people_you(p.name),
                      style: FormPillStyle.selected,
                    )
                  : FormPill(
                      leading: avatar(p.name, selected: true),
                      label: p.name,
                      trailingIcon: Icons.close_rounded,
                      style: FormPillStyle.selected,
                      semanticsLabel: gloc.wizard_people_remove(p.name),
                      tooltip: gloc.wizard_people_remove(p.name),
                      onTap: () => state.removeParticipant(i),
                    ),
          ],
        ),
        const SizedBox(height: 16),
        // Same field as the expense description and the pickers' add field.
        TextField(
          controller: _name,
          focusNode: _focus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _add(state),
          onChanged: (_) => setState(() {}),
          style: FormTheme.getFieldTextStyle(context),
          decoration:
              FormTheme.getCardDecoration(
                fillColor: theme.colorScheme.raisedSurface,
                borderColor: CardOutline.colorFor(theme.brightness),
                focusColor: theme.colorScheme.primary,
                errorColor: theme.colorScheme.error,
                hintText: gloc.wizard_people_add_hint,
              ).copyWith(
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton.filled(
                    onPressed: _name.text.trim().isEmpty
                        ? null
                        : () => _add(state),
                    tooltip: gloc.add_participant,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ),
              ),
        ),
        const SizedBox(height: 16),
        WizardNote(gloc.wizard_participants_section_hint),
      ],
    );
  }
}
