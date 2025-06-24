import 'package:flutter/material.dart';
import '../../trips_storage.dart';
import '../../app_localizations.dart';
import 'base_flat_card.dart';
import '../../trip/detail_page/trip_detail_page.dart';

class TodaySpentCard extends StatelessWidget {
  final Trip trip;
  const TodaySpentCard({required this.trip, super.key});

  @override
  Widget build(BuildContext context) {
    final todayTotal = trip.expenses
        .where((e) =>
            e.date.year == DateTime.now().year &&
            e.date.month == DateTime.now().month &&
            e.date.day == DateTime.now().day)
        .fold<double>(0, (sum, e) => sum + e.amount);
    // Localizzazione
    final locale = Localizations.localeOf(context).languageCode;
    final loc = AppLocalizations(locale);
    final label = loc.get('today');
    return BaseFlatCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(trip: trip),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              Baseline(
                baseline: 38, // valore empirico per displaySmall
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  '${todayTotal.round()}',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 4),
              Baseline(
                baseline: 44, // leggermente più in basso per la currency
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  trip.currency,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
