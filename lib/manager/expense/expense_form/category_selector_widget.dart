import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'inline_select_field.dart';

class CategorySelectorWidget extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory? selectedCategory;
  final void Function(ExpenseCategory?) onCategorySelected;
  final Future<void> Function() onAddCategory;
  final Future<void> Function(String)? onAddCategoryInline;
  final TextStyle? textStyle;
  final bool fullEdit;
  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    this.onAddCategoryInline,
    this.textStyle,
    this.fullEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    Future<void> openPicker() async {
      final picked = await showSelectionBottomSheet<ExpenseCategory>(
        context: context,
        items: categories,
        selected: selectedCategory,
        gloc: gloc,
        sheetTitle: gloc.category,
        itemLabel: (c) => c.name,
        onAddItemInline: onAddCategoryInline,
        addItemHint: gloc.category_name,
      );
      if (picked != null && picked != selectedCategory) {
        onCategorySelected(picked);
      }
    }

    if (fullEdit) {
      return InlineSelectField(
        icon: AppIcons.category,
        label: selectedCategory?.name ?? gloc.category_placeholder,
        onTap: openPicker,
        enabled: true,
        semanticsLabel: gloc.category,
        textStyle: textStyle,
        showArrow: true,
      );
    }

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: openPicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.category, size: 20, color: theme.colorScheme.onSurface),
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
          const SizedBox(width: 4),
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
