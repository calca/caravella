import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/currency_display.dart';

/// Small KPI card consistent with app dark surfaces.
class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final String currency;
  final String? subtitle;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.currency,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use latest Material 3 surface token (surfaceVariant deprecated)
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
    final semanticLabel = subtitle != null
        ? '$title: $formattedValue (${subtitle!})'
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
          child: Column(
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
              CurrencyDisplay(
                value: value,
                currency: currency,
                valueFontSize: 22,
                currencyFontSize: 12,
                showDecimals: true,
                alignment: MainAxisAlignment.start,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
