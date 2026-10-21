import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// Category selector: a "Category" label above category pills, ordered
/// last-used-first, with inline add and an overflow "more" pill when there
/// are many categories. Rendered identically in the compact and the
/// extended expense form.
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
    this.singleLine = false,
  });

  /// One line of pills, the rest behind "+N" (quick-add sheet).
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionLabel(gloc.category),
        ChipSelectorRow<ExpenseCategory>(
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
          singleLine: singleLine,
        ),
      ],
    );
  }
}
