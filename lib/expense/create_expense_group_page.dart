import 'package:flutter/material.dart';
import '../manager/group/add_new_expenses_group.dart';

/// A simple wrapper around AddNewExpensesGroupPage that provides a unified interface for
/// creating a new expense group from different places in the app.
class CreateExpenseGroupPage extends StatelessWidget {
  const CreateExpenseGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddNewExpensesGroupPage();
  }
}
