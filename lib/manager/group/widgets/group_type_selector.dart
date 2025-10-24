import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/expense_group_type.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import 'section_header.dart';
import 'section_flat.dart';
import 'selection_tile.dart';

/// Widget for selecting the expense group type.
/// Displays a list of available types with their associated icons.
class GroupTypeSelector extends StatelessWidget {
  const GroupTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final controller = context.read<GroupFormController>();

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
                return Column(
                  children: ExpenseGroupType.values.map((type) {
                    final isSelected = selectedType == type;
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
                        },
                        borderRadius: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ],
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
