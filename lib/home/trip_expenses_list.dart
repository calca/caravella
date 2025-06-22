import 'package:flutter/material.dart';
import '../trips_storage.dart';
import '../app_localizations.dart';
import '../widgets/trip_amount_card.dart';

class TripExpensesList extends StatelessWidget {
  final Trip? currentTrip;
  final AppLocalizations loc;
  const TripExpensesList(
      {super.key, required this.currentTrip, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: 1.0, // Use a fixed opacity value
        child: currentTrip == null
            ? const SizedBox.shrink()
            : (currentTrip!.expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/home/no_expense.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentTrip!.expenses.length > 3
                        ? 3
                        : currentTrip!.expenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final sortedExpenses = List.of(currentTrip!.expenses)
                        ..sort((a, b) => b.date.compareTo(a.date));
                      final expense = sortedExpenses[i];
                      return TripAmountCard(
                        title: expense.description,
                        coins: expense.amount.toInt(),
                        checked: true,
                        paidBy: expense.paidBy,
                        category: null,
                        date: expense.date,
                        currency: currentTrip!.currency,
                      );
                    },
                  )),
      ),
    );
  }
}
