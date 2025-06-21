import 'package:flutter/material.dart';
import '../trips_storage.dart';
import '../app_localizations.dart';

class TripExpensesList extends StatelessWidget {
  final Trip? currentTrip;
  final AppLocalizations loc;
  const TripExpensesList({super.key, required this.currentTrip, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: 0.3,
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
                        const SizedBox(height: 16),
                        Text(loc.get('no_expenses'), style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentTrip!.expenses.length > 5 ? 5 : currentTrip!.expenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final sortedExpenses = List.of(currentTrip!.expenses)
                        ..sort((a, b) => b.date.compareTo(a.date));
                      final expense = sortedExpenses[i];
                      return _TaskCard(
                        title: expense.description,
                        coins: expense.amount.toInt(),
                        checked: true,
                      );
                    },
                  )),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final int coins;
  final bool checked;
  const _TaskCard({required this.title, required this.coins, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: checked ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: checked ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, color: checked ? Theme.of(context).colorScheme.primary : Colors.grey),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              if (coins > 0) ...[
                Text('$coins', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
