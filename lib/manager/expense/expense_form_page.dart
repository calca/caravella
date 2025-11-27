import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'expense_form_component.dart';

/// Full-screen page for creating or editing an expense
class ExpenseFormPage extends StatelessWidget {
  final ExpenseGroup group;
  final ExpenseDetails? initialExpense;
  final void Function(ExpenseDetails) onExpenseSaved;
  final void Function(String) onCategoryAdded;
  final VoidCallback? onDelete;

  const ExpenseFormPage({
    super.key,
    required this.group,
    this.initialExpense,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          initialExpense != null ? gloc.edit_expense : gloc.new_expense,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ExpenseFormComponent(
            initialExpense: initialExpense,
            participants: group.participants,
            categories: group.categories,
            tripStartDate: group.startDate,
            tripEndDate: group.endDate,
            shouldAutoClose: true,
            fullEdit: true,
            groupTitle: group.title,
            currency: group.currency,
            autoLocationEnabled: group.autoLocationEnabled,
            onExpenseAdded: onExpenseSaved,
            onCategoryAdded: onCategoryAdded,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }
}
