import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_category.dart';
import '../../../widgets/selection_bottom_sheet.dart';

class CategorySelectorWidget extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory? selectedCategory;
  final void Function(ExpenseCategory?) onCategorySelected;
  final Future<void> Function() onAddCategory;
  final AppLocalizations loc;
  final TextStyle? textStyle;
  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.loc,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () async {
        final picked = await showSelectionBottomSheet<ExpenseCategory>(
          context: context,
            items: categories,
            selected: selectedCategory,
            loc: loc,
            itemLabel: (c) => c.name,
            onAddItem: () async {
              await onAddCategory();
            },
            addItemTooltip: loc.get('add_category'),
        );
        if (picked != null && picked != selectedCategory) {
          onCategorySelected(picked);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category, size: 20, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 8),
          Text(
            selectedCategory?.name ?? loc.get('category_placeholder'),
            style: (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.expand_more, size: 20, color: theme.colorScheme.onPrimary),
        ],
      ),
    );
  }
}
