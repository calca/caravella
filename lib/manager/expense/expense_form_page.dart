import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: initialExpense != null ? gloc.edit_expense : gloc.new_expense,
                description: '${gloc.group} ${group.title}',
              ),
              const SizedBox(height: 24),
              ExpenseFormComponent(
                initialExpense: initialExpense,
                participants: group.participants,
                categories: group.categories,
                tripStartDate: group.startDate,
                tripEndDate: group.endDate,
                shouldAutoClose: true,
                fullEdit: true,
                showGroupHeader: false,
                currency: group.currency,
                autoLocationEnabled: group.autoLocationEnabled,
                onExpenseAdded: onExpenseSaved,
                onCategoryAdded: onCategoryAdded,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
