import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../trips_storage.dart';

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
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...trip.participants.map((p) {
            final total = trip.expenses
                .where((e) => e.paidBy == p)
                .fold<double>(0, (sum, e) => sum + e.amount);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.primary
                                .withAlpha((0.15 * 255).toInt()),
                            child: Text(p.isNotEmpty ? p[0].toUpperCase() : '?',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(p, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Text(
                        loc.get('amount_with_currency', params: {
                          'amount': total.toStringAsFixed(2),
                          'currency': trip.currency
                        }),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          Divider(),
          const SizedBox(height: 18),
          Text(loc.get('expenses_by_category'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...trip.categories.map((cat) {
            final total = trip.expenses
                .where((e) => e.description == cat)
                .fold<double>(0, (sum, e) => sum + e.amount);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.label_outline,
                              size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 6),
                          Text(cat, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Text(
                        loc.get('amount_with_currency', params: {
                          'amount': total.toStringAsFixed(2),
                          'currency': trip.currency
                        }),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (trip.expenses.any((e) =>
              e.description.isEmpty ||
              !trip.categories.contains(e.description)))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Text(loc.get('uncategorized'),
                          style: theme.textTheme.bodyMedium),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Text(
                        loc.get('amount_with_currency', params: {
                          'amount': trip.expenses
                              .where((e) =>
                                  e.description.isEmpty ||
                                  !trip.categories.contains(e.description))
                              .fold<double>(0, (sum, e) => sum + e.amount)
                              .toStringAsFixed(2),
                          'currency': trip.currency
                        }),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
