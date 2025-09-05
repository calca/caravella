import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_category.dart';
import '../../../data/category_service.dart';
import '../../../widgets/selection_bottom_sheet.dart';
import 'inline_select_field.dart';
import '../../../themes/form_theme.dart';

class CategorySelectorWidget extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory? selectedCategory;
  final void Function(ExpenseCategory?) onCategorySelected;
  final Future<void> Function() onAddCategory;
  final Future<void> Function(String)? onAddCategoryInline;
  final TextStyle? textStyle;
  final bool fullEdit;
  final CategoryService? categoryService; // New parameter for global category search
  
  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    this.onAddCategoryInline,
    this.textStyle,
    this.fullEdit = false,
    this.categoryService, // New optional parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;
    final gloc = gen.AppLocalizations.of(context);

    Future<void> openPicker() async {
      // Use global category search if categoryService is provided and inline add is available
      final useGlobalSearch = categoryService != null && onAddCategoryInline != null;
      
      final picked = await showSelectionBottomSheet<ExpenseCategory>(
        context: context,
        items: categories,
        selected: selectedCategory,
        gloc: gloc,
        sheetTitle: gloc.category,
        itemLabel: (c) => c.name,
        onAddItemInline: onAddCategoryInline,
        addItemHint: gloc.category_name,
        searchFunction: useGlobalSearch 
            ? (query) => categoryService!.getCategorySuggestions(query)
            : null,
      );
      if (picked != null && picked != selectedCategory) {
        onCategorySelected(picked);
      }
    }

    if (fullEdit) {
      return InlineSelectField(
        icon: Icons.category_outlined,
        label: selectedCategory?.name ?? gloc.category_placeholder,
        onTap: openPicker,
        enabled: true,
        semanticsLabel: gloc.category,
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
      onPressed: openPicker,
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
              selectedCategory?.name ?? gloc.category_placeholder,
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
