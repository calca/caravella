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
  final bool enabled;
  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    this.onAddCategoryInline,
    this.textStyle,
    this.fullEdit = false,
    this.enabled = true,
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
        sheetTitle: gloc.category,
        itemLabel: (c) => c.name,
        onAddItemInline: onAddCategoryInline,
        addItemHint: gloc.category_name,
        addLabel: gloc.add,
        cancelLabel: gloc.cancel,
        addCategoryLabel: gloc.add_category,
        alreadyExistsMessage: '${gloc.category_name} ${gloc.already_exists}',
      );
      if (picked != null && picked != selectedCategory) {
        onCategorySelected(picked);
      }
    }

    if (fullEdit) {
      return InlineSelectField(
        icon: AppIcons.category,
        label: selectedCategory?.name ?? gloc.category_placeholder,
        onTap: enabled ? openPicker : null,
        enabled: enabled,
        semanticsLabel: gloc.category,
        textStyle: textStyle,
        showArrow: enabled,
      );
    }

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        foregroundColor: theme.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      onPressed: enabled ? openPicker : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 5),
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
