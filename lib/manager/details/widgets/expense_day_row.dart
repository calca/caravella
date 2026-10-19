import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// An expense row with its date shown like a calendar on the left (day of
/// the week, or the month with [showMonth], above the day number), the
/// title with "payer · category" below, and the amount. Used inside the
/// group page's week cards and in the search results.
class ExpenseDayRow extends StatelessWidget {
  final ExpenseDetails expense;
  final String currency;
  final VoidCallback? onTap;

  /// Highlights this text in the title (search).
  final String? highlightQuery;

  /// Show the month instead of the weekday (results spanning months).
  final bool showMonth;

  const ExpenseDayRow({
    super.key,
    required this.expense,
    required this.currency,
    this.onTap,
    this.highlightQuery,
    this.showMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final date = expense.date;
    final top = DateFormat(
      showMonth ? 'MMM' : 'EEE',
      locale,
    ).format(date).replaceAll('.', '').toUpperCase();
    final day = DateFormat('d', locale).format(date);
    final title = expense.name ?? '';
    final subtitle = '${expense.paidBy.name} · ${expense.category.name}';

    return Semantics(
      button: onTap != null,
      label: [
        title,
        subtitle,
        DateFormat.MMMMEEEEd(locale).format(date),
        '${(expense.amount ?? 0).toStringAsFixed(2)} $currency',
      ].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      top,
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: s.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      day,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightedText(
                      text: title,
                      query: highlightQuery ?? '',
                      maxLines: MediaQuery.textScalerOf(context).scale(1) > 1.3
                          ? 2
                          : 1,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    HighlightedText(
                      text: subtitle,
                      query: highlightQuery ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CurrencyDisplay(
                value: expense.amount ?? 0,
                currency: currency,
                valueFontSize: 20,
                currencyFontSize: 12,
                showDecimals: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
