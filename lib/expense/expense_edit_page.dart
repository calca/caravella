import 'package:flutter/material.dart';
import '../data/expense_details.dart';
import '../app_localizations.dart';
import 'expense_form_component.dart';
import '../manager/detail_page/tabs/expenses_tab.dart';
import '../widgets/caravella_app_bar.dart';
import '../widgets/themed_outlined_button.dart';

class ExpenseEditPage extends StatelessWidget {
  final ExpenseDetails expense;
  final List<String> participants;
  final List<String> categories;
  final AppLocalizations loc;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  const ExpenseEditPage({
    super.key,
    required this.expense,
    required this.participants,
    required this.categories,
    required this.loc,
    this.tripStartDate,
    this.tripEndDate,
  });

  void _onSave(BuildContext context, ExpenseDetails updated) {
    Navigator.of(context).pop(ExpenseActionResult(updatedExpense: updated));
  }

  void _onDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.get('delete_expense')),
        content: Text(loc.get('delete_expense_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.get('delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (!context.mounted) return; // Fix use_build_context_synchronously
      Navigator.of(context).pop(ExpenseActionResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaravellaAppBar(
        actions: [
          ThemedOutlinedButton.icon(
            onPressed: () => _onDelete(context),
            icon: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.error),
            size: 40,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ExpenseFormComponent(
          participants: participants,
          categories: categories,
          initialExpense: expense,
          onExpenseAdded: (updated) => _onSave(context, updated),
          tripStartDate: tripStartDate,
          tripEndDate: tripEndDate,
          shouldAutoClose:
              false, // Non chiudere automaticamente perché è la ExpenseEditPage che gestisce la navigazione
        ),
      ),
    );
  }
}
