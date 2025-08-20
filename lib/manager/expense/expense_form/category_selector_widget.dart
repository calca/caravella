import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/expense_category.dart';
import '../../../widgets/selection_bottom_sheet.dart';

class CategorySelectorWidget extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory? selectedCategory;
  final void Function(ExpenseCategory?) onCategorySelected;
  final Future<void> Function() onAddCategory;
  final TextStyle? textStyle;
  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: borderColor.withValues(alpha: 0.8), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final picked = await showSelectionBottomSheet<ExpenseCategory>(
          context: context,
          items: categories,
          selected: selectedCategory,
          gloc: gen.AppLocalizations.of(context),
          itemLabel: (c) => c.name,
          onAddItem: () async {
            await onAddCategory();
          },
          addItemTooltip: gen.AppLocalizations.of(context).add_category,
        );
        if (picked != null && picked != selectedCategory) {
          onCategorySelected(picked);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              selectedCategory?.name ?? gen.AppLocalizations.of(context).category_placeholder,
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
