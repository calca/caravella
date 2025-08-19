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
    final borderColor = theme.colorScheme.outlineVariant;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: borderColor.withValues(alpha: 0.8), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Icon(
            Icons.person_outline,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              selected ?? loc.get('participants_label'),
              overflow: TextOverflow.ellipsis,
              style: (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
