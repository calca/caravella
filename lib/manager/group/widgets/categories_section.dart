import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'editable_name_list.dart';

class CategoriesSection extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final void Function(String) onAddCategory;
  final void Function(int, String) onEditCategory;
  final void Function(int) onRemoveCategory;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onEditCategory,
    required this.onRemoveCategory,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return EditableNameList(
      title: loc.categories,
      requiredMark: true,
      description: loc.categories_description,
      items: categories.map((e) => e.name).toList(),
      addLabel: loc.add_category,
      hintLabel: loc.category_name,
      editTooltip: loc.edit_category,
      deleteTooltip: loc.delete,
      saveTooltip: loc.save,
      cancelTooltip: loc.cancel,
      addTooltip: loc.add,
      duplicateError: '${loc.category_name} ${loc.already_exists}',
      onAdd: onAddCategory,
      onEdit: onEditCategory,
      onDelete: onRemoveCategory,
      itemIcon: AppIcons.category,
    );
  }
}
