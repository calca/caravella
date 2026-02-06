import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'inline_select_field.dart';

class ParticipantSelectorWidget extends StatelessWidget {
  final List<String> participants;
  final String? selectedParticipant;
  final void Function(String) onParticipantSelected;
  final Future<void> Function(String)? onAddParticipantInline;
  final TextStyle? textStyle;
  final bool fullEdit; // when true mimic inline row style
  final bool enabled;
  const ParticipantSelectorWidget({
    super.key,
    required this.participants,
    required this.selectedParticipant,
    required this.onParticipantSelected,
    this.onAddParticipantInline,
    this.textStyle,
    this.fullEdit = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedParticipant;
    final gloc = gen.AppLocalizations.of(context);

    Future<void> openPicker() async {
      final picked = await showSelectionBottomSheet<String>(
        context: context,
        items: participants,
        selected: selected,
        sheetTitle: gloc.participants_label,
        itemLabel: (p) => p,
        onAddItemInline: onAddParticipantInline,
        addItemHint: gloc.participant_name,
        addLabel: gloc.add,
        cancelLabel: gloc.cancel,
        addCategoryLabel: gloc.add_participant,
        alreadyExistsMessage: '${gloc.participant_name} ${gloc.already_exists}',
      );
      if (picked != null && picked != selectedParticipant) {
        onParticipantSelected(picked);
      }
    }

    // Disable selection when there's only one participant and no inline add, or when disabled
    final canSelect =
        (participants.length > 1 || onAddParticipantInline != null) && enabled;

    if (fullEdit) {
      return InlineSelectField(
        icon: AppIcons.participant,
        label: selected ?? gloc.participants_label,
        onTap: canSelect ? openPicker : null,
        enabled: canSelect,
        semanticsLabel: gloc.paid_by,
        textStyle: textStyle,
        showArrow: canSelect,
      );
    }

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        foregroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      onPressed: canSelect ? openPicker : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 5),
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
          const SizedBox(width: 4),
          if (canSelect)
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
