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
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 900;

    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const HomeBackground(),
          Flex(
            direction: Axis.vertical,
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

              // Area principale con layout unificato
              Expanded(
                flex: 1,
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    // Header - sempre presente, animato per posizione
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      padding: zenMode
                          ? const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32)
                          : EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                      child: Center(
                        child: HomeTripCard(trip: trip),
                      ),
                    ),

                    // Spazio flessibile tra header e cards (solo in normal mode)
                    if (!zenMode)
                      Flexible(
                        flex: 0,
                        child: SizedBox(
                            height:
                                isSmallScreen ? 8 : (isMediumScreen ? 16 : 24)),
                      ),

                    // Cards area - Expanded fisso con animazione interna
                    Expanded(
                      flex: isSmallScreen ? 3 : 4,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: !zenMode
                            ? Padding(
                                key: const ValueKey('trip-cards'),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: HomeTripCards(
                                  currentTrip: trip,
                                  loc: loc,
                                  onTripAdded: onTripAdded,
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('empty-cards')),
                      ),
                    ),

                    // Spazio inferiore flessibile (solo in normal mode)
                    if (!zenMode)
                      Flexible(
                        flex: 0,
                        child: SizedBox(
                            height:
                                isSmallScreen ? 8 : (isMediumScreen ? 12 : 16)),
                      ),
                  ],
                ),
              ),

              // Bottom bar
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: CaravellaBottomBar(
                  loc: loc,
                  onTripAdded: onTripAdded,
                  currentTrip: trip,
                  showLeftButtons: !zenMode,
                  showAddButton: true,
                  animationDuration: const Duration(milliseconds: 600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
