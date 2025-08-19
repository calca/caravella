import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/selection_bottom_sheet.dart';

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
    final theme = Theme.of(context);
    final selected = selectedParticipant;
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: participants.isEmpty
          ? null
          : () async {
              final picked = await showSelectionBottomSheet<String>(
                context: context,
                items: participants,
                selected: selected,
                loc: loc,
                itemLabel: (p) => p,
              );
              if (picked != null && picked != selectedParticipant) {
                onParticipantSelected(picked);
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 20, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              selected ?? loc.get('participants_label'),
              overflow: TextOverflow.ellipsis,
              style: (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
