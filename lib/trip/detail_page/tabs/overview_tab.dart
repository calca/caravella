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
                    backgroundColor: theme.colorScheme.primary
                        .withAlpha((0.1 * 255).toInt()),
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
        ],
      ),
    );
  }
}
