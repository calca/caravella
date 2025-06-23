import 'package:flutter/material.dart';
import '../../../widgets/trip_amount_card.dart';
import '../../../trips_storage.dart';
import '../../../app_localizations.dart';
import 'expense_edit_page.dart';

class ExpensesTab extends StatefulWidget {
  final Trip trip;
  final AppLocalizations loc;
  const ExpensesTab({super.key, required this.trip, required this.loc});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  late List<Expense> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.trip.expenses);
  }

  Future<void> _openEditPage(int i) async {
    final result = await Navigator.of(context).push<ExpenseActionResult>(
      MaterialPageRoute(
        builder: (context) => ExpenseEditPage(
          expense: _expenses[i],
          participants: widget.trip.participants,
          categories: widget.trip.categories,
          loc: widget.loc,
        ),
      ),
    );
    if (result != null) {
      if (result.deleted) {
        setState(() {
          _expenses.removeAt(i);
        });
      } else if (result.updatedExpense != null) {
        setState(() {
          _expenses[i] = result.updatedExpense!;
        });
      }
      widget.trip.expenses
        ..clear()
        ..addAll(_expenses);
      final trips = await TripsStorage.readTrips();
      final idx = trips.indexWhere((t) =>
          t.title == widget.trip.title &&
          t.startDate == widget.trip.startDate &&
          t.endDate == widget.trip.endDate);
      if (idx != -1) {
        trips[idx] = widget.trip;
        await TripsStorage.writeTrips(trips);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_expenses.isEmpty) {
      return Center(child: Text(widget.loc.get('no_expenses')));
    }
    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, i) {
        final expense = _expenses[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: GestureDetector(
            onTap: () => _openEditPage(i),
            child: TripAmountCard(
              title: expense.description,
              coins: expense.amount.toInt(),
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
  final Expense? updatedExpense;
  final bool deleted;
  ExpenseActionResult({this.updatedExpense, this.deleted = false});
}
