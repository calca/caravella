import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/trip.dart';
import '../../../widgets/currency_display.dart';

class OverviewTab extends StatelessWidget {
  final Trip trip;
  const OverviewTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context).languageCode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView(
        children: [
          // Card rimossa: solo sezioni partecipanti e categorie
          const SizedBox(height: 8),
          Text(loc.get('expenses_by_participant'),
              style: theme.textTheme.titleMedium?.copyWith()),
          const SizedBox(height: 8),
          ...trip.participants.map((p) {
            final total = trip.expenses
                .where((e) => e.paidBy == p)
                .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CurrencyDisplay(
                    value: total,
                    currency: trip.currency,
                    valueFontSize: 14.0,
                    currencyFontSize: 12.0,
                    alignment: MainAxisAlignment.end,
                    showDecimals: true,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(loc.get('expenses_by_category'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          ...trip.categories.map((cat) {
            final total = trip.expenses
                .where((e) => e.category == cat)
                .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.label_outline,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CurrencyDisplay(
                    value: total,
                    currency: trip.currency,
                    valueFontSize: 14.0,
                    currencyFontSize: 12.0,
                    alignment: MainAxisAlignment.end,
                    showDecimals: true,
                  ),
                ],
              ),
            );
          }),
          if (trip.expenses.any((e) =>
              e.category.isEmpty || !trip.categories.contains(e.category)))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.get('uncategorized'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  CurrencyDisplay(
                    value: trip.expenses
                        .where((e) =>
                            e.category.isEmpty ||
                            !trip.categories.contains(e.category))
                        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0)),
                    currency: trip.currency,
                    valueFontSize: 14.0,
                    currencyFontSize: 12.0,
                    alignment: MainAxisAlignment.end,
                    showDecimals: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
