import 'package:flutter/material.dart';

class TripAmountCard extends StatelessWidget {
  final String title;
  final int coins;
  final bool checked;
  final String? paidBy;
  final String? category;
  final DateTime? date;
  final String currency;
  const TripAmountCard({
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surfaceGrey =
        isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color paidByColor =
        isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    final Color categoryColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Container(
      decoration: BoxDecoration(
        color: surfaceGrey, // Flat background ancora più light
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
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                    ),
                    if ((paidBy != null && paidBy!.isNotEmpty) ||
                        category != null ||
                        date != null)
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
                            if (date != null) ...[
                              Expanded(
                                  child: Container()), // push date to right
                              Icon(Icons.calendar_today,
                                  size: 13, color: textColor.withOpacity(0.7)),
                              const SizedBox(width: 2),
                              Text(
                                '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Amount e currency
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (coins > 0) ...[
                    Text('$coins',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(width: 2),
                    Text(currency,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 18,
                        )),
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
