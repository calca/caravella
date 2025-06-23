import 'package:flutter/material.dart';
import '../../../widgets/trip_amount_card.dart';
import '../../../trips_storage.dart';
import '../../../app_localizations.dart';

class ExpensesTab extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  const ExpensesTab({super.key, required this.trip, required this.loc});

  @override
  Widget build(BuildContext context) {
    if (trip.expenses.isEmpty) {
      return Center(child: Text(loc.get('no_expenses')));
    }
    return ListView.builder(
      itemCount: trip.expenses.length,
      itemBuilder: (context, i) {
        final expense = trip.expenses[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: TripAmountCard(
            title: expense.description,
            coins: expense.amount.toInt(),
            checked: true,
            paidBy: expense.paidBy,
            category: null,
            date: expense.date,
            currency: trip.currency,
          ),
        );
      },
    );
  }
}
