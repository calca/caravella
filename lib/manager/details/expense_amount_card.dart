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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (paidBy != null && paidBy!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              paidBy!,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Sezione destra: Importo e data allineati
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Importo
                    CurrencyDisplay(
                      value: coins.toDouble(),
                      currency: currency,
                      valueFontSize: 28.0,
                      currencyFontSize: 16.0,
                      alignment: MainAxisAlignment.end,
                      showDecimals: false,
                    ),
                    // Data - allineata a destra sotto l'importo
                    if (date != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: colorScheme.outline.withOpacity(0.7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            // Categoria in fondo se presente
            if (category != null && category!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 13,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category!,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
