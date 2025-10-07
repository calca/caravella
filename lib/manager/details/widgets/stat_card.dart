import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/currency_display.dart';

/// Small KPI card consistent with app dark surfaces.
class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final String currency;
  final String? subtitle;
  final List<InlineSpan>? subtitleSpans;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing; // optional action button or icon on the right
  final double? percent; // 0-100
  final bool inlineHeader; // when true, show title and value on same row
  final int? subtitleMaxLines; // allow override of max lines for subtitle

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.currency,
    this.subtitle,
    this.subtitleSpans,
    this.icon,
    this.leading,
    this.trailing,
    this.percent,
    this.inlineHeader = false,
    this.subtitleMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use latest Material 3 surface token
    final surface = theme.colorScheme.surface;
    final locale = Localizations.maybeLocaleOf(context)?.toString();

    String formattedValue;
    try {
      if (locale != null) {
        formattedValue = NumberFormat.currency(
          locale: locale,
          symbol: currency,
        ).format(value);
      } else {
        formattedValue = '$value$currency';
      }
    } catch (_) {
      formattedValue = '$value$currency';
    }

    final semanticLabel =
        (subtitle ?? _inlineSpansToPlain(subtitleSpans)) != null
        ? '$title: $formattedValue (${(subtitle ?? _inlineSpansToPlain(subtitleSpans))!})'
        : '$title: $formattedValue';

    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(icon, size: 24, color: theme.colorScheme.outline),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (inlineHeader) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CurrencyDisplay(
                              value: value,
                              currency: currency,
                              valueFontSize: 18,
                              currencyFontSize: 12,
                              showDecimals: true,
                              alignment: MainAxisAlignment.end,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        CurrencyDisplay(
                          value: value,
                          currency: currency,
                          valueFontSize: 22,
                          currencyFontSize: 12,
                          showDecimals: true,
                          alignment: MainAxisAlignment.start,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                      if (percent != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: ((percent! / 100).clamp(0, 1)),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                                color: theme.colorScheme.surfaceDim,
                                backgroundColor: theme.colorScheme.surfaceDim
                                    .withAlpha((0.4 * 255).toInt()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${percent!.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if ((subtitleSpans != null &&
                              subtitleSpans!.isNotEmpty) ||
                          subtitle != null) ...[
                        const SizedBox(height: 8),
                        if (subtitleSpans != null && subtitleSpans!.isNotEmpty)
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              children: subtitleSpans,
                            ),
                            maxLines: subtitleMaxLines ?? 3,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: subtitleMaxLines ?? 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extract plain text from inline spans for semantic labels
  String? _inlineSpansToPlain(List<InlineSpan>? spans) {
    if (spans == null || spans.isEmpty) return null;
    final buffer = StringBuffer();
    for (final s in spans) {
      if (s is TextSpan) {
        buffer.write(s.text ?? '');
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }
}

/// Informational card variant (no numeric value) sharing same visual style.
class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.3,
    );
    final semanticLabel = '$title: ${subtitle.replaceAll('\n', ', ')}';

    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (icon != null)
                    Icon(icon, size: 20, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
