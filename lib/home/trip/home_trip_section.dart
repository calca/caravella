import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/trip.dart';
import 'home_trip_header.dart';
import 'home_trip_cards.dart';
import '../../widgets/caravella_bottom_bar.dart';
import '../widgets/home_background.dart';

class HomeTripSection extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  final bool zenMode;
  final ValueChanged<bool> onZenModeChanged;
  const HomeTripSection({
    super.key,
    required this.trip,
    required this.loc,
    required this.onTripAdded,
    required this.zenMode,
    required this.onZenModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
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
                    IconButton(
                      onPressed: () => onZenModeChanged(!zenMode),
                      icon: Icon(
                        zenMode
                            ? Icons.flight_outlined
                            : Icons.flight_takeoff_outlined,
                        color: zenMode
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                      ),
                      tooltip:
                          zenMode ? 'Disattiva zen mode' : 'Attiva zen mode',
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
                    child: HomeTripCard(trip: trip),
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
                          child: HomeTripCards(
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
      ),
    );
  }
}
