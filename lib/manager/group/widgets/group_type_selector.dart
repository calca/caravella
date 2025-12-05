import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import 'section_flat.dart';
import 'selection_tile.dart';

/// Widget for selecting the expense group type.
/// Shows only the selected type and opens a bottom sheet for selection.
class GroupTypeSelector extends StatelessWidget {
  const GroupTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return SectionFlat(
      title: '',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: gloc.group_type,
              description: gloc.group_type_description,
              padding: EdgeInsets.zero,
              spacing: 4,
            ),
            const SizedBox(height: 8),
            Selector<GroupFormState, ExpenseGroupType?>(
              selector: (context, state) => state.groupType,
              builder: (context, selectedType, child) {
                return SelectionTile(
                  leading: Icon(
                    selectedType?.icon ?? Icons.category_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: selectedType != null
                      ? _getTypeName(gloc, selectedType)
                      : 'Seleziona tipo',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTypeSelector(context),
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showTypeSelector(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final controller = context.read<GroupFormController>();
    final currentType = context.read<GroupFormState>().groupType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GroupBottomSheetScaffold(
        title: gloc.group_type,
        scrollable: false,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...ExpenseGroupType.values.map((type) {
              final isSelected = currentType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectionTile(
                  leading: Icon(
                    type.icon,
                    size: 24,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  title: _getTypeName(gloc, type),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.setGroupType(
                      isSelected ? null : type,
                      autoPopulateCategories: !isSelected,
                    );
                    Navigator.of(context).pop();
                  },
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getTypeName(gen.AppLocalizations gloc, ExpenseGroupType type) {
    switch (type) {
      case ExpenseGroupType.travel:
        return gloc.group_type_travel;
      case ExpenseGroupType.personal:
        return gloc.group_type_personal;
      case ExpenseGroupType.family:
        return gloc.group_type_family;
      case ExpenseGroupType.other:
        return gloc.group_type_other;
    }
  }
}
