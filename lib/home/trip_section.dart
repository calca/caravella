import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../trips_storage.dart';
import 'trip_expenses_list.dart';
import 'caravella_bottom_bar.dart';

class TripSection extends StatelessWidget {
  final Trip? currentTrip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;

  const TripSection({
    super.key,
    required this.currentTrip,
    required this.loc,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    if (currentTrip == null) {
      return const _NoTripWidget();
    }
    return _TripWithExpensesWidget(
      currentTrip: currentTrip!,
      loc: loc,
      onTripAdded: onTripAdded,
    );
  }
}

class _NoTripWidget extends StatelessWidget {
  const _NoTripWidget();

  @override
  Widget build(BuildContext context) {
    final loc = (context.findAncestorWidgetOfExactType<TripSection>() as TripSection).loc;
    final onTripAdded = (context.findAncestorWidgetOfExactType<TripSection>() as TripSection).onTripAdded;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.get('latest_expenses'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Image.asset(
            'assets/images/home/no_travels.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          CaravellaBottomBar(loc: loc, onTripAdded: onTripAdded, currentTrip: null),
        ],
      ),
    );
  }
}

class _TripWithExpensesWidget extends StatelessWidget {
  final Trip currentTrip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;

  const _TripWithExpensesWidget({
    required this.currentTrip,
    required this.loc,
    required this.onTripAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.get('latest_expenses'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TripExpensesList(currentTrip: currentTrip, loc: loc),
          CaravellaBottomBar(loc: loc, onTripAdded: onTripAdded, currentTrip: currentTrip),
        ],
      ),
    );
  }
}
