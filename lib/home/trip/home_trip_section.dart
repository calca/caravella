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

              // Area principale con layout flessibile
              Expanded(
                flex: 1,
                child: zenMode
                    ? _buildZenModeLayout()
                    : _buildNormalModeLayout(isSmallScreen, isMediumScreen),
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

  Widget _buildZenModeLayout() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Center(
        key: const ValueKey('zen-card'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: HomeTripCard(trip: trip),
        ),
      ),
    );
  }

  Widget _buildNormalModeLayout(bool isSmallScreen, bool isMediumScreen) {
    return Flex(
      direction: Axis.vertical,
      children: [
        // Header con hide animation
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: zenMode ? 0.0 : 1.0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: isSmallScreen ? 8 : 12,
            ),
            child: HomeTripCard(trip: trip),
          ),
        ),

        // Spazio flessibile tra header e cards
        Flexible(
          flex: 0,
          child:
              SizedBox(height: isSmallScreen ? 8 : (isMediumScreen ? 16 : 24)),
        ),

        // Cards area con flex controllato
        Expanded(
          flex: isSmallScreen ? 3 : 4, // Più spazio per le cards
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: zenMode ? 0.0 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: HomeTripCards(
                currentTrip: trip,
                loc: loc,
                onTripAdded: onTripAdded,
              ),
            ),
          ),
        ),

        // Spazio inferiore flessibile
        Flexible(
          flex: 0,
          child:
              SizedBox(height: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16)),
        ),
      ],
    );
  }
}
