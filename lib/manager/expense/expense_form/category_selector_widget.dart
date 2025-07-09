import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

class CategorySelectorWidget extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;
  final Future<void> Function() onAddCategory;
  final AppLocalizations loc;

  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etichetta con asterisco per campo obbligatorio (solo se ci sono categorie)
        if (categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${loc.get('category')} *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: categories.isNotEmpty
                        ? categories.map((cat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: selectedCategory == cat,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: selectedCategory == cat
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: selectedCategory == cat
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                backgroundColor: selectedCategory == cat
                                    ? null
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                selectedColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                side: BorderSide(
                                  color: selectedCategory == cat
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                onSelected: (selected) {
                                  onCategorySelected(selected ? cat : null);
                                },
                              ),
                            );
                          }).toList()
                        : [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                loc.get('no_categories'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ),
            ThemedOutlinedButton.icon(
              onPressed: onAddCategory,
              icon: const Icon(Icons.add, size: 22),
            ),
          ],
        ),
      ],
    );
  }
}
