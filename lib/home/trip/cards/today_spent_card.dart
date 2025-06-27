import 'package:flutter/material.dart';
import '../../../data/trip.dart';
import '../../../app_localizations.dart';
import 'base_flat_card.dart';
import '../../../trip/detail_page/trip_detail_page.dart';
import '../../../widgets/currency_display.dart';

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
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
    // Localizzazione
    final locale = Localizations.localeOf(context).languageCode;
    final loc = AppLocalizations(locale);
    final label = loc.get('today');
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
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribuisce lo spazio
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith()),
            const SizedBox(height: 4),
            Expanded(
              // Permette al contenuto di espandersi
              child: Align(
                alignment: Alignment
                    .bottomRight, // Allinea il totale in basso a destra
                child: CurrencyDisplay(
                  value: todayTotal,
                  currency: trip.currency,
                  valueFontSize: 24.0, // Più piccolo per le card
                  currencyFontSize: 12.0, // Proporzionato
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
