import 'package:flutter/material.dart';
import '../../data/expense.dart';
import '../../app_localizations.dart';
import '../add_expense_component.dart';
import 'tabs/expenses_tab.dart';
import '../../widgets/caravella_app_bar.dart';

class ExpenseEditPage extends StatelessWidget {
  final Expense expense;
  final List<String> participants;
  final List<String> categories;
  final AppLocalizations loc;
  final DateTime tripStartDate;
  final DateTime tripEndDate;
  const ExpenseEditPage({
    super.key,
    required this.expense,
    required this.participants,
    required this.categories,
    required this.loc,
    required this.tripStartDate,
    required this.tripEndDate,
  });

  void _onSave(BuildContext context, Expense updated) {
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
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: Colors.transparent),
              padding: const EdgeInsets.all(0),
              minimumSize: const Size(40, 40),
            ),
            onPressed: () => _onDelete(context),
            child: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: AddExpenseComponent(
          participants: participants,
          categories: categories,
          initialExpense: expense,
          onExpenseAdded: (updated) => _onSave(context, updated),
          tripStartDate: tripStartDate,
          tripEndDate: tripEndDate,
        ),
      ),
    );
  }
}
