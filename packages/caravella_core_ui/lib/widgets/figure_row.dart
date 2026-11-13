import 'package:material_ui/material_ui.dart';

import 'currency_display.dart';

/// One figure of a [FigureRow]: a small label over an amount.
class FigureRowItem {
  final String label;
  final double value;
  final String currency;

  /// After the amount, on its line (the budget ring on "Today").
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Replaces label and amount for screen readers.
  final String? semanticLabel;

  const FigureRowItem({
    required this.label,
    required this.value,
    required this.currency,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });
}

/// Figures side by side with a thin divider between them ("Total | Today"),
/// in [color], straight on the card or header they sit on. With large text
/// they go one under the other instead of shrinking.
class FigureRow extends StatelessWidget {
  final List<FigureRowItem> items;
  final Color color;
  final double valueFontSize;

  const FigureRow({
    super.key,
    required this.items,
    required this.color,
    this.valueFontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = color.withValues(alpha: 0.8);
    Widget figure(FigureRowItem item) {
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CurrencyDisplay(
                    value: item.value,
                    currency: item.currency,
                    valueFontSize: valueFontSize,
                    currencyFontSize: valueFontSize * 0.55,
                    showDecimals: true,
                    alignment: MainAxisAlignment.start,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (item.trailing case final trailing?) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ],
      );
      final onTap = item.onTap;
      if (onTap == null) {
        return item.semanticLabel == null
            ? content
            : Semantics(
                label: item.semanticLabel,
                excludeSemantics: true,
                child: content,
              );
      }
      return Semantics(
        button: true,
        label: item.semanticLabel,
        onTap: onTap,
        excludeSemantics: item.semanticLabel != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: content,
          ),
        ),
      );
    }

    final large = MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;
    if (large) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items) ...[
            if (item != items.first) const SizedBox(height: 8),
            figure(item),
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items) ...[
            if (item != items.first)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: 1,
                  child: ColoredBox(color: color.withValues(alpha: 0.2)),
                ),
              ),
            Flexible(child: figure(item)),
          ],
        ],
      ),
    );
  }
}
