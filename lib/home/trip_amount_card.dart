import 'package:flutter/material.dart';

class TripAmountCard extends StatelessWidget {
  final String title;
  final int coins;
  final bool checked;
  final String? paidBy;
  final String? category;
  final DateTime? date;
  const TripAmountCard({
    required this.title,
    required this.coins,
    required this.checked,
    this.paidBy,
    this.category,
    this.date,
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
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    if (paidBy != null && paidBy!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        paidBy!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: paidByColor,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (coins > 0) ...[
                    Text('$coins',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(width: 2),
                    Text('€',
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
          if (category != null || date != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (category != null) ...[
                  Icon(Icons.category, size: 18, color: categoryColor),
                  const SizedBox(width: 4),
                  Text(category!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: categoryColor)),
                  const SizedBox(width: 12),
                ],
                if (date != null) ...[
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text('${date!.day}/${date!.month}/${date!.year}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.teal)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
