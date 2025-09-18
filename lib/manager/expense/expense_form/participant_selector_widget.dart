import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../config/app_icons.dart';
import '../../../widgets/selection_bottom_sheet.dart';
import '../../../data/participant_service.dart';
import '../../../data/model/expense_participant.dart';
import 'inline_select_field.dart';
import '../../../themes/form_theme.dart';

class ParticipantSelectorWidget extends StatelessWidget {
  final List<String> participants;
  final String? selectedParticipant;
  final void Function(String) onParticipantSelected;
  final TextStyle? textStyle;
  final bool fullEdit; // when true mimic inline row style
  final ParticipantService? participantService; // Optional service for global search
  
  const ParticipantSelectorWidget({
    super.key,
    required this.participants,
    required this.selectedParticipant,
    required this.onParticipantSelected,
    this.textStyle,
    this.fullEdit = false,
    this.participantService, // Add this for global participant search
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedParticipant;
    final borderColor = theme.colorScheme.outlineVariant;
    final gloc = gen.AppLocalizations.of(context);

    Future<void> openPicker() async {
      if (participants.isEmpty && participantService == null) return;
      
      // Use global participant search if participantService is provided
      if (participantService != null) {
        // Find the currently selected participant object for proper comparison
        ExpenseParticipant? currentSelection;
        if (selectedParticipant != null) {
          currentSelection = await participantService!.findParticipantByName(selectedParticipant!);
        }
        
        final picked = await showSelectionBottomSheet<ExpenseParticipant>(
          context: context,
          items: [], // Items will be populated by search function
          selected: currentSelection,
          gloc: gloc,
          sheetTitle: gloc.participants_label,
          itemLabel: (participant) => participant.name,
          searchFunction: (query) => participantService!.getParticipantSuggestions(query),
        );
        if (picked != null && picked.name != selectedParticipant) {
          onParticipantSelected(picked.name);
        }
      } else {
        // Use local participants (backward compatibility)
        final picked = await showSelectionBottomSheet<String>(
          context: context,
          items: participants,
          selected: selectedParticipant,
          gloc: gloc,
          sheetTitle: gloc.participants_label,
          itemLabel: (p) => p,
        );
        if (picked != null && picked != selectedParticipant) {
          onParticipantSelected(picked);
        }
      }
    }

    if (fullEdit) {
      return InlineSelectField(
        icon: AppIcons.participant,
        label: selected ?? gloc.participants_label,
        onTap: openPicker,
        enabled: participants.isNotEmpty || participantService != null,
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
      onPressed: (participants.isEmpty && participantService == null) ? null : openPicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.participant,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              selected ?? gloc.participants_label,
              overflow: TextOverflow.ellipsis,
              style: (textStyle ?? FormTheme.getSelectTextStyle(context))
                  ?.copyWith(
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
