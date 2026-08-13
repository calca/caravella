import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'icon_leading_field.dart';

/// Category selector: a horizontally scrolling row of category chips,
/// ordered last-used-first, with inline add and an overflow "more" chip
/// when there are many categories. Rendered identically in the compact and
/// the extended expense form.
class CategorySelectorWidget extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory> onCategorySelected;
  final Future<void> Function() onAddCategory;
  final Future<void> Function(String)? onAddCategoryInline;
  final bool enabled;

  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    this.onAddCategoryInline,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return IconLeadingField(
      icon: Icon(AppIcons.category),
      semanticsLabel: gloc.category,
      tooltip: gloc.category,
      child: ChipSelectorRow<ExpenseCategory>(
        items: categories,
        selected: selectedCategory,
        itemLabel: (c) => c.name,
        onSelected: onCategorySelected,
        enabled: enabled,
        onAddItemInline: onAddCategoryInline,
        addItemHint: gloc.category_name,
        addLabel: gloc.add,
        cancelLabel: gloc.cancel,
        addCategoryLabel: gloc.add_category,
        alreadyExistsMessage: '${gloc.category_name} ${gloc.already_exists}',
        sheetTitle: gloc.category,
      ),
    );
  }
}
