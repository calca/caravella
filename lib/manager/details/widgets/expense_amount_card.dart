import 'package:flutter/material.dart';
import '../../../widgets/base_card.dart';
import '../../../widgets/currency_display.dart';

class ExpenseAmountCard extends StatelessWidget {
  final String title;
  final int coins;
  final bool checked;
  final String? paidBy;
  final String? category;
  final DateTime? date;
  final String currency;
  final VoidCallback? onTap;
  const ExpenseAmountCard({
    required this.title,
    required this.coins,
    required this.checked,
    this.paidBy,
    this.category,
    this.date,
    this.currency = '€',
    this.onTap,
    super.key,
  });

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (d == today) {
      return 'Today, $time';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}, $time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      backgroundColor: colorScheme.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ...existing code...
            // Main info (title, person, date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((paidBy != null && paidBy!.isNotEmpty) ||
                      (category != null && category!.isNotEmpty)) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (paidBy != null && paidBy!.isNotEmpty) ...[
                          Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            paidBy!,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                        if (category != null && category!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.local_offer_outlined,
                            size: 15,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category!,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatDateTime(date!),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Amount
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: CurrencyDisplay(
                  value: coins.toDouble(),
                  currency: currency,
                  valueFontSize: 32.0,
                  currencyFontSize: 14.0,
                  alignment: MainAxisAlignment.end,
                  showDecimals: false,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// End of ExpenseAmountCard
