import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'categories_section.dart';
import 'package:caravella_core/caravella_core.dart';
import '../group_form_controller.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class CategoriesEditor extends StatelessWidget {
  const CategoriesEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    return CategoriesSection(
      categories: state.categories,
      onAddCategory: (name) => state.addCategory(ExpenseCategory(name: name)),
      onEditCategory: (i, name) => state.editCategory(i, name),
      onRemoveCategory: (i) async {
        final loc = gen.AppLocalizations.of(context);
        final messenger = ScaffoldMessenger.of(context);
        final removed = await controller.removeCategoryIfUnused(i);
        if (!removed) {
          AppToast.showFromMessenger(
            messenger,
            loc.cannot_delete_assigned_category,
            type: ToastType.info,
          );
        }
      },
    );
  }
}
