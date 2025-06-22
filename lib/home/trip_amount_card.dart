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
    final Color surfaceGrey = Colors.grey.shade200;
    final Color shadow = Theme.of(context).shadowColor.withOpacity(0.10);
    return Container(
      decoration: BoxDecoration(
        color: surfaceGrey, // Flat grey background
        borderRadius: BorderRadius.circular(18),
        // No border
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Removed the task icon
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                    ),
                    if (paidBy != null && paidBy!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        paidBy!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
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
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                    const SizedBox(width: 2),
                    const Text('€',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  Icon(Icons.category, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(category!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600)),
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
