import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class ParticipantSelectorWidget extends StatelessWidget {
  final List<String> participants;
  final String? selectedParticipant;
  final void Function(String?) onParticipantSelected;
  final AppLocalizations loc;

  const ParticipantSelectorWidget({
    super.key,
    required this.participants,
    required this.selectedParticipant,
    required this.onParticipantSelected,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etichetta con asterisco per campo obbligatorio
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${loc.get('paid_by')} *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: participants.isNotEmpty
                        ? participants.map((p) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(p),
                                selected: selectedParticipant == p,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: selectedParticipant == p
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: selectedParticipant == p
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                backgroundColor: selectedParticipant == p
                                    ? null
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                  color: selectedParticipant == p
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                onSelected: (selected) {
                                  onParticipantSelected(selected ? p : null);
                                },
                              ),
                            );
                          }).toList()
                        : [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                loc.get('participants_label'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
