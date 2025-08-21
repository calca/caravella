import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'categories_section.dart';
import 'group_form_state.dart';
import '../../../../data/expense_category.dart';

class CategoriesEditor extends StatelessWidget {
  const CategoriesEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    return CategoriesSection(
      categories: state.categories,
      onAddCategory: (name) => state.addCategory(ExpenseCategory(name: name)),
      onEditCategory: (i, name) => state.editCategory(i, name),
      onRemoveCategory: (i) => state.removeCategory(i),
    );
  }
}
