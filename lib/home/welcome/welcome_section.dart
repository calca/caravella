import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../trip/trip_add_page.dart';
import '../../widgets/caravella_bottom_bar.dart';
import 'welcome_card.dart';
import '../../data/expense_group.dart';
import '../widgets/home_background.dart';
import '../../state/locale_notifier.dart';

typedef RefreshCallback = void Function();

class WelcomeSection extends StatelessWidget {
  final RefreshCallback? onTripAdded;
  const WelcomeSection({super.key, this.onTripAdded});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    return SizedBox(
      height: MediaQuery.of(context).size.height -
          120, // Altezza fissa meno spazio per header/padding
      child: Stack(
        children: [
          const HomeBackground(),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height -
                    200, // Altezza fissa per evitare conflitti con Expanded
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: WelcomeCard(
                      loc: loc,
                      onAddTrip: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TripAddPage(),
                          ),
                        );
                        if (result == true && onTripAdded != null) {
                          onTripAdded!();
                        }
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
                  currentTrip: ExpenseGroup.empty(),
                  showAddButton: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
