import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../widgets/base_card.dart';
import '../../../widgets/currency_display.dart';
import '../../../data/model/expense_participant.dart';
import 'group_header.dart';

class ExpenseAmountCard extends StatelessWidget {
  final String title;
  final int coins;
  final bool checked;
  final ExpenseParticipant? paidBy;
  final String? category;
  final DateTime? date;
  final String currency;
  final VoidCallback? onTap;
  // Optional: text to highlight (case-insensitive) inside title
  final String? highlightQuery;
  const ExpenseAmountCard({
    required this.title,
    required this.coins,
    required this.checked,
    this.paidBy,
    this.category,
    this.date,
    this.currency = '€',
    this.onTap,
    this.highlightQuery,
    super.key,
  });

  String _formatDateTime(DateTime date) {
    // Use timeago for relative dates
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      backgroundColor: colorScheme.surfaceContainerHighest,
      noBorder: true,
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
                  // Title with optional highlight
                  _buildHighlightedTitle(context, title, highlightQuery),
                  if ((paidBy != null) ||
                      (category != null && category!.isNotEmpty)) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (paidBy != null) ...[
                          Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            paidBy!.name,
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
                          Icons.schedule_outlined,
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
            // Amount and Avatar
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CurrencyDisplay(
                  value: coins.toDouble(),
                  currency: currency,
                  valueFontSize: 32.0,
                  currencyFontSize: 14.0,
                  alignment: MainAxisAlignment.end,
                  showDecimals: false,
                  fontWeight: FontWeight.w500,
                ),
                if (paidBy != null) ...[
                  const SizedBox(height: 8),
                  ParticipantAvatar(
                    participant: paidBy!,
                    size: 32,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// End of ExpenseAmountCard

extension on ExpenseAmountCard {
  Widget _buildHighlightedTitle(
    BuildContext context,
    String text,
    String? query,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
    if (query == null || query.trim().isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final index = lower.indexOf(q, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = index + q.length;
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style, children: spans),
    );
  }
}
