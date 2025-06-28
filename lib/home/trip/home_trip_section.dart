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
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicTopOffset = (screenHeight * 0.35).clamp(220.0, 320.0); // 35% dell'altezza schermo, min 220px, max 320px
    
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const HomeBackground(),
          Column(
            children: [
              // Zen mode toggle button - sempre visibile
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
                                .withValues(alpha: 0.6),
                      ),
                      tooltip:
                          zenMode ? 'Disattiva zen mode' : 'Attiva zen mode',
                    ),
                  ],
                ),
              ),

              // Area principale con animazione di scivolamento fluida
              Expanded(
                child: Stack(
                  children: [
                    // Card principale che scivola verso il centro
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      alignment: zenMode ? Alignment.center : Alignment.topCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        margin: EdgeInsets.only(
                          left: zenMode ? 24 : 8,
                          right: zenMode ? 24 : 8,
                          top: zenMode ? 0 : 16, // Maggiore spazio dall'alto
                          bottom: zenMode ? 0 : 24, // Maggiore spazio dal basso
                        ),
                        child: IntrinsicHeight(
                          child: HomeTripCard(trip: trip),
                        ),
                      ),
                    ),

                    // Cards area che scivola verso il basso quando zen mode
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      top: zenMode ? screenHeight : dynamicTopOffset, // Spazio dinamico basato sul device
                      left: 8,
                      right: 8,
                      bottom: zenMode ? -200 : 0, // Esce dalla parte inferiore
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: zenMode ? 0.0 : 1.0,
                        child: HomeTripCards(
                          currentTrip: trip,
                          loc: loc,
                          onTripAdded: onTripAdded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom bar con animazione coordinata
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                        child: child,
                      );
                    },
                    child: CaravellaBottomBar(
                      key: ValueKey(zenMode),
                      loc: loc,
                      onTripAdded: onTripAdded,
                      currentTrip: trip,
                      showLeftButtons: !zenMode,
                      showAddButton: true,
                      animationDuration: const Duration(milliseconds: 600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
