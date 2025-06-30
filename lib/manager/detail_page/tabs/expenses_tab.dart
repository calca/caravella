import 'package:flutter/material.dart';
import '../../../widgets/no_expense.dart';
import '../../../data/expense_details.dart';
import '../../../data/expense_group.dart';
import '../trip_amount_card.dart';
import '../../../data/expense_group_storage.dart';
import '../../../app_localizations.dart';
import '../../../expense/expense_edit_page.dart';

class ExpensesTab extends StatefulWidget {
  final ExpenseGroup trip;
  final AppLocalizations loc;
  const ExpensesTab({super.key, required this.trip, required this.loc});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  late List<ExpenseDetails> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.trip.expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _openEditPage(int i) async {
    final expenseId = _expenses[i].id;
    final result = await Navigator.of(context).push<ExpenseActionResult>(
      MaterialPageRoute(
        builder: (context) => ExpenseEditPage(
          expense: _expenses[i],
          participants: widget.trip.participants,
          categories: widget.trip.categories,
          loc: widget.loc,
          tripStartDate: widget.trip.startDate,
          tripEndDate: widget.trip.endDate,
        ),
      ),
    );
    if (result != null) {
      if (result.deleted) {
        setState(() {
          _expenses.removeWhere((e) => e.id == expenseId);
        });
      } else if (result.updatedExpense != null) {
        setState(() {
          final idx = _expenses.indexWhere((e) => e.id == expenseId);
          if (idx != -1) _expenses[idx] = result.updatedExpense!;
        });
      }
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      widget.trip.expenses
        ..clear()
        ..addAll(_expenses);
      final trips = await ExpenseGroupStorage.getAllGroups();
      final tripIdx = trips.indexWhere((t) => t.id == widget.trip.id);
      if (tripIdx != -1) {
        trips[tripIdx] = widget.trip;
        await ExpenseGroupStorage.writeTrips(trips);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_expenses.isEmpty) {
      return Center(
        child: NoExpense(
          semanticLabel: widget.loc.get('no_expense_label'),
        ),
      );
    }
    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, i) {
        final expense = _expenses[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          child: GestureDetector(
            onTap: () => _openEditPage(i),
            child: TripAmountCard(
              title: expense.category,
              coins: (expense.amount ?? 0).toInt(),
              checked: true,
              paidBy: expense.paidBy,
              category: null,
              date: expense.date,
              currency: widget.trip.currency,
            ),
          ),
        );
      },
    );
  }
}

class ExpenseActionResult {
  final ExpenseDetails? updatedExpense;
  final bool deleted;
  ExpenseActionResult({this.updatedExpense, this.deleted = false});
}
