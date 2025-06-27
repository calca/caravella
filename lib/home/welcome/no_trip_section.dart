import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../trip/add_trip_page.dart';
import '../../widgets/caravella_bottom_bar.dart';
import 'no_trip_card.dart';
import '../../data/trip.dart';
import '../widgets/home_background.dart';
import '../../state/locale_notifier.dart';

typedef RefreshCallback = void Function();

class NoTripSection extends StatelessWidget {
  final RefreshCallback? onTripAdded;
  const NoTripSection({super.key, this.onTripAdded});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    return Stack(
      fit: StackFit.expand,
      children: [
        const HomeBackground(),
        Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: NoTripCard(
                    loc: loc,
                    onAddTrip: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddTripPage(),
                        ),
                      );
                      if (result == true && onTripAdded != null) onTripAdded!();
                    },
                    opacity: 0.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CaravellaBottomBar(
                loc: loc,
                onTripAdded: onTripAdded ?? () {},
                currentTrip: Trip.empty(),
                showAddButton: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
