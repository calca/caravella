import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/trip.dart';
import '../../../trip/detail_page/trip_detail_page.dart';
import 'base_flat_card.dart';

class CategoryCard extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  const CategoryCard({super.key, required this.trip, required this.loc});

  @override
  Widget build(BuildContext context) {
    // NOTA: Non esiste un campo 'category' su Expense, uso 'description' come fallback per raggruppare le spese.
    final Map<String, double> totals = {};
    for (final e in trip.expenses) {
      final cat = e.category; // fallback: description usata come categoria
      totals[cat] = (totals[cat] ?? 0) + (e.amount ?? 0);
    }
    final top = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return BaseFlatCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripDetailPage(trip: trip),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.max, // Occupa tutto lo spazio verticale
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.get('category'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Expanded(
              // Espande per occupare lo spazio rimanente
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Allinea il contenuto in basso
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (top.isEmpty)
                    Text('-', style: Theme.of(context).textTheme.titleLarge)
                  else
                    ...top.take(2).map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Icon(Icons.category,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(e.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium)),
                              Text(
                                  '${trip.currency} ${e.value.toStringAsFixed(2)}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// InfoCard è stata rinominata e spostata in category_card.dart
