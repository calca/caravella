import 'package:flutter/material.dart';
import '../../widgets/base_card.dart';
import '../../widgets/currency_display.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sezione sinistra: Titolo e chi ha pagato
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo della spesa - principale
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Chi ha pagato - allineato alla baseline della data
                    Row(
                      children: [
                        if (paidBy != null && paidBy!.isNotEmpty) ...[
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            paidBy!,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        // Spacer per spingere la data a destra
                        const Spacer(),
                        // Data - allineata alla baseline del paidBy
                        if (date != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Sezione destra: Solo importo
              CurrencyDisplay(
                value: coins.toDouble(),
                currency: currency,
                valueFontSize: 22.0,
                currencyFontSize: 16.0,
                alignment: MainAxisAlignment.end,
                showDecimals: false,
              ),
            ],
          ),
          // Categoria in fondo se presente
          if (category != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 12,
                  color: colorScheme.outline.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  category!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
