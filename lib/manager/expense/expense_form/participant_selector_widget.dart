import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_choice_chip.dart';

class ParticipantSelectorWidget extends StatelessWidget {
  final List<String> participants;
  final String? selectedParticipant;
  final void Function(String) onParticipantSelected;
  final AppLocalizations loc;
  final TextStyle? textStyle;
  const ParticipantSelectorWidget({
    super.key,
    required this.participants,
    required this.selectedParticipant,
    required this.onParticipantSelected,
    required this.loc,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: participants.isNotEmpty
          ? participants.map((p) {
              final selected = selectedParticipant == p;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ThemedChoiceChip(
                  label: p,
                  selected: selected,
                  textStyle: (textStyle ?? Theme.of(context).textTheme.bodySmall)
                      ?.copyWith(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selectedTextColor: Theme.of(context).colorScheme.onPrimary,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: selected
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                  showCheckmark: false,
                  avatar: null,
                  onSelected: () => onParticipantSelected(p),
                ),
              );
            }).toList()
          : [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  loc.get('participants_label'),
                  style: textStyle ?? Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
    );
  }
}
