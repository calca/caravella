import 'package:flutter/material.dart';
import '../../../trips_storage.dart';
import '../../../app_localizations.dart';
import '../../add_expense_sheet.dart';
import 'expenses_tab.dart';

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
  bool _deleted = false;

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
    if (confirm == true) {
      setState(() {
        _deleted = true;
      });
      Navigator.of(context).pop(ExpenseActionResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.get('edit_expense')),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: widget.loc.get('delete'),
            onPressed: _onDelete,
          ),
        ],
      ),
      body: AddExpenseSheet(
        participants: widget.participants,
        categories: widget.categories,
        initialExpense: _expense,
        onExpenseAdded: _onSave,
      ),
    );
  }
}
