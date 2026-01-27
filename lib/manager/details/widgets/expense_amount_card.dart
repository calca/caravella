import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';
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
  // Whether to show the date row. Default true for existing callers.
  final bool showDate;
  // Compact layout for dense lists
  final bool compact;
  // When true, remove horizontal padding so the card spans full row
  final bool fullWidth;
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
    this.showDate = true,
    this.compact = false,
    this.fullWidth = false,
    super.key,
  });

  String _formatDateTime(BuildContext context, DateTime date) {
    // Use timeago for relative dates
    // Check the current locale and set timeago accordingly
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'it') {
      timeago.setLocaleMessages('it', timeago.ItMessages());
      return timeago.format(date, locale: 'it');
    } else {
      return timeago.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BaseCard(
      padding: fullWidth
          ? EdgeInsets.symmetric(horizontal: 0, vertical: compact ? 10 : 16)
          : (compact
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
      backgroundColor: Colors.transparent,
      noBorder: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Participant Avatar on the left
            if (paidBy != null) ...[
              ParticipantAvatar(participant: paidBy!, size: compact ? 40 : 52),
              SizedBox(width: compact ? 8 : 12),
            ],
            // Main info (title, person, date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with optional highlight
                  _buildHighlightedTitle(context, title, highlightQuery),
                  if ((paidBy != null) ||
                      (category != null && category!.isNotEmpty)) ...[
                    SizedBox(height: compact ? 4 : 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // if (paidBy != null) ...[
                        //   Icon(
                        //     Icons.person_outline_rounded,
                        //     size: 15,
                        //     color: colorScheme.onSurface,
                        //   ),
                        //   const SizedBox(width: 4),
                        //   Text(
                        //     paidBy!.name,
                        //     style: textTheme.labelSmall?.copyWith(
                        //       color: colorScheme.onSurface,
                        //       fontWeight: FontWeight.w400,
                        //     ),
                        //   ),
                        // ],
                        if (category != null && category!.isNotEmpty) ...[
                          //const SizedBox(width: 12),
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
                  if (date != null && showDate) ...[
                    SizedBox(height: compact ? 4 : 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: compact ? 11 : 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        SizedBox(width: compact ? 2 : 3),
                        Text(
                          _formatDateTime(context, date!),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: compact ? 10 : 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Amount
            CurrencyDisplay(
              value: coins.toDouble(),
              currency: currency,
              valueFontSize: compact ? 24.0 : 32.0,
              currencyFontSize: compact ? 12.0 : 14.0,
              alignment: MainAxisAlignment.end,
              showDecimals: false,
              fontWeight: FontWeight.w500,
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
