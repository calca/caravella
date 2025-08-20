import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/expense_category.dart';
import 'section_list_tile.dart';
import 'selection_tile.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              gen.AppLocalizations.of(context).categories,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...categories.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return SectionListTile(
            icon: Icons
                .category_outlined, // not shown, but required by constructor
            title: c.name,
            subtitle: null,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            borderColor: Theme.of(
              context,
            ).colorScheme.primaryFixed.withAlpha(128),
            onEdit: () {
              final editController = TextEditingController(text: c.name);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(gen.AppLocalizations.of(context).edit_category),
                  content: TextField(
                    controller: editController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: gen.AppLocalizations.of(context).category_name,
                      hintText: gen.AppLocalizations.of(
                        context,
                      ).category_name_hint,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        onEditCategory(i, val.trim());
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(gen.AppLocalizations.of(context).cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final val = editController.text.trim();
                        if (val.isNotEmpty) {
                          onEditCategory(i, val);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(gen.AppLocalizations.of(context).save),
                    ),
                  ],
                ),
              );
            },
            onDelete: () => onRemoveCategory(i),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SelectionTile(
            leading: const Icon(Icons.add),
            title: gen.AppLocalizations.of(context).add_category,
            onTap: () {
              final TextEditingController categoryController =
                  TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(gen.AppLocalizations.of(context).add_category),
                  content: TextField(
                    controller: categoryController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: gen.AppLocalizations.of(context).category_name,
                      hintText: gen.AppLocalizations.of(
                        context,
                      ).category_name_hint,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        onAddCategory(val.trim());
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(gen.AppLocalizations.of(context).cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final val = categoryController.text.trim();
                        if (val.isNotEmpty) {
                          onAddCategory(val);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(gen.AppLocalizations.of(context).add),
                    ),
                  ],
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ],
    );
  }
}
