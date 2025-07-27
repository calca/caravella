import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${loc.get('paid_by')} *',
            style: textStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Row(
          children: participants.isNotEmpty
              ? participants.map((p) {
                  final selected = selectedParticipant == p;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        p,
                        style:
                            (textStyle ?? Theme.of(context).textTheme.bodySmall)
                                ?.copyWith(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => onParticipantSelected(p),
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
        ),
      ],
    );
  }
}
