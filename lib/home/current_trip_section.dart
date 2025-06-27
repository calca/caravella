import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/trip.dart';
import '../home/top_card/current_trip_card.dart';
import '../home/trip_section.dart';
import '../widgets/caravella_bottom_bar.dart';
import 'home_background.dart';

class CurrentTripSection extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  final bool zenMode;
  final ValueChanged<bool> onZenModeChanged;
  const CurrentTripSection({
    super.key,
    required this.trip,
    required this.loc,
    required this.onTripAdded,
    required this.zenMode,
    required this.onZenModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const HomeBackground(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Switch(
                    value: zenMode,
                    onChanged: onZenModeChanged,
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: Padding(
                key: ValueKey(zenMode),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: IntrinsicHeight(
                  child: CurrentTripCard(trip: trip),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: zenMode
                    ? const SizedBox.shrink(key: ValueKey('zen'))
                    : Padding(
                        key: const ValueKey('normal'),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TripSection(
                          currentTrip: trip,
                          loc: loc,
                          onTripAdded: onTripAdded,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: CaravellaBottomBar(
                loc: loc,
                onTripAdded: onTripAdded,
                currentTrip: trip,
                showLeftButtons: !zenMode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
