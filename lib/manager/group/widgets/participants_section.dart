import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/expense_participant.dart';
import 'section_list_tile.dart';
import 'selection_tile.dart';

class ParticipantsSection extends StatelessWidget {
  final List<ExpenseParticipant> participants;
  final void Function(String) onAddParticipant;
  final void Function(int, String) onEditParticipant;
  final void Function(int) onRemoveParticipant;
  final TextEditingController participantController;

  const ParticipantsSection({
    super.key,
    required this.participants,
    required this.onAddParticipant,
    required this.onEditParticipant,
    required this.onRemoveParticipant,
    required this.participantController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              gen.AppLocalizations.of(context).participants,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...participants.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return SectionListTile(
            icon:
                Icons.person_outline, // not shown, but required by constructor
            title: p.name,
            subtitle: null,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            borderColor: Theme.of(
              context,
            ).colorScheme.primaryFixedDim.withAlpha(128),
            onEdit: () {
              final editController = TextEditingController(text: p.name);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    gen.AppLocalizations.of(context).edit_participant,
                  ),
                  content: TextField(
                    controller: editController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: gen.AppLocalizations.of(
                        context,
                      ).participant_name,
                      hintText: gen.AppLocalizations.of(
                        context,
                      ).participant_name_hint,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        onEditParticipant(i, val.trim());
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(gen.AppLocalizations.of(context).cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final val = editController.text.trim();
                        if (val.isNotEmpty) {
                          onEditParticipant(i, val);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(gen.AppLocalizations.of(context).save),
                    ),
                  ],
                ),
              );
            },
            onDelete: () => onRemoveParticipant(i),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SelectionTile(
            leading: const Icon(Icons.add),
            title: gen.AppLocalizations.of(context).add_participant,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(gen.AppLocalizations.of(context).add_participant),
                  content: TextField(
                    controller: participantController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: gen.AppLocalizations.of(
                        context,
                      ).participant_name,
                      hintText: gen.AppLocalizations.of(
                        context,
                      ).participant_name_hint,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        onAddParticipant(val.trim());
                        participantController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(gen.AppLocalizations.of(context).cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final val = participantController.text.trim();
                        if (val.isNotEmpty) {
                          onAddParticipant(val);
                          participantController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(gen.AppLocalizations.of(context).add),
                    ),
                  ],
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ],
    );
  }
}
