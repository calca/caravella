import 'package:flutter/material.dart';

class ExpenseAmountCard extends StatelessWidget {
  final String title;
  final int coins;
  final bool checked;
  final String? paidBy;
  final String? category;
  final DateTime? date;
  final String currency;
  const ExpenseAmountCard({
    required this.title,
    required this.coins,
    required this.checked,
    this.paidBy,
    this.category,
    this.date,
    this.currency = '€',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color paidByColor = Theme.of(context).colorScheme.primary;
    final Color categoryColor = Theme.of(context).colorScheme.secondary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Background trasparente
        borderRadius: BorderRadius.circular(18),
        // Nessuna ombra
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                          ),
                    ),
                    if ((paidBy != null && paidBy!.isNotEmpty) ||
                        category != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (paidBy != null && paidBy!.isNotEmpty) ...[
                              Icon(Icons.person, size: 15, color: paidByColor),
                              const SizedBox(width: 2),
                              Text(
                                paidBy!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: paidByColor,
                                      fontSize: 12,
                                    ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (category != null) ...[
                              Icon(Icons.category,
                                  size: 15, color: categoryColor),
                              const SizedBox(width: 2),
                              Text(
                                category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: categoryColor,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Amount e currency sulla stessa linea, allineati in basso, data sotto
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Baseline(
                        baselineType: TextBaseline.alphabetic,
                        baseline: 24, // valore adatto per l'allineamento
                        child: Text('$coins',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: textColor)),
                      ),
                      const SizedBox(width: 4),
                      Baseline(
                        baselineType: TextBaseline.alphabetic,
                        baseline: 24, // stesso valore per currency
                        child: Text(currency,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13, // più piccolo dell'amount
                            )),
                      ),
                    ],
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
