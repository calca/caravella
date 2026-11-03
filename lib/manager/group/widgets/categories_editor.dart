import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'categories_section.dart';
import 'package:caravella_core/caravella_core.dart';
import '../group_form_controller.dart';

class CategoriesEditor extends StatelessWidget {
  const CategoriesEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    final loc = gen.AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoriesSection(
          showHeader: false,
          categories: state.categories,
          onAddCategory: (name) =>
              state.addCategory(ExpenseCategory(name: name)),
          onEditCategory: (i, name) => state.editCategory(i, name),
          onRemoveCategory: controller.removeCategoryIfUnused,
          // A category some expenses use stays: the bin says why.
          deleteBlockedReason: (i) {
            final id = state.categories[i].id;
            final used =
                (state.originalGroup?.expenses ?? const <ExpenseDetails>[])
                    .where((e) => e.category.id == id)
                    .length;
            return used == 0 ? null : loc.cannot_delete_category_used(used);
          },
        ),
      ],
    );
  }
}
