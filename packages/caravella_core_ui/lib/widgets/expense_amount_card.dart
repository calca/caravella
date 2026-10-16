import 'package:material_ui/material_ui.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:caravella_core/caravella_core.dart';
import 'avatars.dart';
import 'base_card.dart';
import 'currency_display.dart';
import '../themes/app_dimens.dart';

class ExpenseAmountCard extends StatelessWidget {
  final String title;
  final double amount;
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
    required this.amount,
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

    final row = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      // The tappable row itself is at least 48dp; the card's vertical padding
      // is trimmed in compact mode so the overall footprint stays the same.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Participant Avatar on the left
            if (paidBy != null) ...[
              ParticipantAvatar(participant: paidBy!, size: compact ? 32 : 52),
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
                        if (category != null && category!.isNotEmpty) ...[
                          //const SizedBox(width: 12),
                          Icon(
                            Icons.local_offer_outlined,
                            size: compact ? 10 : 15,
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
              value: amount,
              currency: currency,
              valueFontSize: compact ? 24.0 : 32.0,
              currencyFontSize: compact ? 12.0 : 14.0,
              alignment: MainAxisAlignment.end,
              showDecimals: true,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );

    return BaseCard(
      padding: fullWidth
          ? EdgeInsets.symmetric(horizontal: 0, vertical: compact ? 5 : 16)
          : (compact
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 5)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
      backgroundColor: Colors.transparent,
      noBorder: true,
      child: onTap != null
          ? Semantics(button: true, child: MergeSemantics(child: row))
          : row,
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
    // Let titles wrap to a second line at large accessibility text sizes
    // instead of truncating after a couple of words.
    final maxLines = MediaQuery.textScalerOf(context).scale(1.0) > 1.3 ? 2 : 1;
    if (query == null || query.trim().isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
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
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
