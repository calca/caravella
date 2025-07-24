import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_category.dart';

class CategoriesSection extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final void Function(String) onAddCategory;
  final void Function(int, String) onEditCategory;
  final void Function(int) onRemoveCategory;
  final AppLocalizations loc;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onEditCategory,
    required this.onRemoveCategory,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  loc.get('categories'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Text('*', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                final TextEditingController categoryController =
                    TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc.get('add_category')),
                    content: TextField(
                      controller: categoryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: loc.get('category_name'),
                        hintText: loc.get('category_name_hint'),
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
                        child: Text(loc.get('cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          final val = categoryController.text.trim();
                          if (val.isNotEmpty) {
                            onAddCategory(val);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(loc.get('add')),
                      ),
                    ],
                  ),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                minimumSize: const Size(54, 54),
              ),
            ),
          ],
        ),
        if (categories.isEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              loc.get('no_categories'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(153), // 0.6 alpha
                  ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          ...categories.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryFixed
                                .withAlpha(128), // 0.5 alpha
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.primaryFixedDim,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                              semanticsLabel: loc.get(
                                'category_name_semantics',
                                params: {'name': c.name},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () {
                      final editController =
                          TextEditingController(text: c.name);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(loc.get('edit_category')),
                          content: TextField(
                            controller: editController,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: loc.get('category_name'),
                              hintText: loc.get('category_name_hint'),
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
                              child: Text(loc.get('cancel')),
                            ),
                            TextButton(
                              onPressed: () {
                                final val = editController.text.trim();
                                if (val.isNotEmpty) {
                                  onEditCategory(i, val);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(loc.get('save')),
                            ),
                          ],
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      minimumSize: const Size(54, 54),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => onRemoveCategory(i),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      foregroundColor: Theme.of(context).colorScheme.error,
                      minimumSize: const Size(54, 54),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
