import 'package:flutter/material.dart';
import '../../trips_storage.dart';
import '../../app_localizations.dart';
import '../add_expense_component.dart';
import 'tabs/expenses_tab.dart';
import '../../widgets/caravella_app_bar.dart';

class ExpenseEditPage extends StatefulWidget {
  final Expense expense;
  final List<String> participants;
  final List<String> categories;
  final AppLocalizations loc;
  const ExpenseEditPage(
      {super.key,
      required this.expense,
      required this.participants,
      required this.categories,
      required this.loc});

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  void _onSave(Expense updated) {
    setState(() {
      _expense = updated;
    });
    Navigator.of(context).pop(ExpenseActionResult(updatedExpense: updated));
  }

  void _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.loc.get('delete_expense')),
        content: Text(widget.loc.get('delete_expense_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(widget.loc.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.loc.get('delete')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm == true) {
      Navigator.of(context).pop(ExpenseActionResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaravellaAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: widget.loc.get('delete'),
            onPressed: _onDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: AddExpenseComponent(
          participants: widget.participants,
          categories: widget.categories,
          initialExpense: _expense,
          onExpenseAdded: _onSave,
        ),
      ),
    );
  }
}
