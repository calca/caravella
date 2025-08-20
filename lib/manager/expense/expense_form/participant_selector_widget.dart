import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../widgets/selection_bottom_sheet.dart';
import 'inline_select_field.dart';

class ParticipantSelectorWidget extends StatelessWidget {
  final List<String> participants;
  final String? selectedParticipant;
  final void Function(String) onParticipantSelected;
  final TextStyle? textStyle;
  final bool fullEdit; // when true mimic inline row style
  const ParticipantSelectorWidget({
    super.key,
    required this.participants,
    required this.selectedParticipant,
    required this.onParticipantSelected,
    this.textStyle,
    this.fullEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedParticipant;
    final borderColor = theme.colorScheme.outlineVariant;
    final gloc = gen.AppLocalizations.of(context);

  Future<void> openPicker() async {
      if (participants.isEmpty) return;
      final picked = await showSelectionBottomSheet<String>(
        context: context,
        items: participants,
        selected: selected,
        gloc: gloc,
        itemLabel: (p) => p,
      );
      if (picked != null && picked != selectedParticipant) {
        onParticipantSelected(picked);
      }
    }

    if (fullEdit) {
      return InlineSelectField(
        icon: Icons.person_outline,
        label: selected ?? gloc.participants_label,
        onTap: openPicker,
        enabled: participants.isNotEmpty,
        semanticsLabel: gloc.paid_by,
        textStyle: textStyle,
      );
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: borderColor.withValues(alpha: 0.8), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
  onPressed: participants.isEmpty ? null : openPicker,
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
              selected ?? gloc.participants_label,
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
