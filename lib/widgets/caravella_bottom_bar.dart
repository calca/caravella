import 'package:flutter/material.dart';
import 'package:org_app_caravella/expense/expense_form_component.dart';
import '../data/expense_group.dart';
import '../data/expense_category.dart';
import '../manager/trips_history_page.dart';
import '../app_localizations.dart';
import '../../data/expense_group_storage.dart';
import '../settings/settings_page.dart';

class CaravellaBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  final ExpenseGroup currentTrip;
  final bool showLeftButtons;
  final bool showAddButton;
  final Duration animationDuration;
  const CaravellaBottomBar({
    super.key,
    required this.loc,
    required this.onTripAdded,
    required this.currentTrip,
    this.showLeftButtons = true,
    this.showAddButton = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    // Usa SafeArea per evitare overlay con la gesture bar e padding inferiore
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Due container separati: uno a sinistra, uno a destra
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left buttons con animazione fluida
                AnimatedSwitcher(
                  duration: animationDuration,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.3, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: showLeftButtons
                      ? Container(
                          key: const ValueKey('left-buttons'),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TripsHistoryPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  loc.get('history').toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  loc.get('settings').toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('no-left-buttons'),
                        ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (currentTrip.id.isNotEmpty && showAddButton)
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 28),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    left: 16,
                                    right: 16,
                                    top: 24,
                                  ),
                                  child: ExpenseFormComponent(
                                    participants: currentTrip.participants
                                        .map((p) => p.name)
                                        .toList(),
                                    categories: currentTrip.categories
                                        .map((c) => c.name)
                                        .toList(),
                                    onExpenseAdded: (expense) async {
                                      final trips = await ExpenseGroupStorage
                                          .getAllGroups();
                                      final idx = trips.indexWhere(
                                          (v) => v.id == currentTrip.id);
                                      if (idx != -1) {
                                        trips[idx].expenses.add(expense);
                                        await ExpenseGroupStorage.writeTrips(
                                            trips);
                                        onTripAdded();
                                      }
                                    },
                                    onCategoryAdded: (newCategory) async {
                                      final trips = await ExpenseGroupStorage
                                          .getAllGroups();
                                      final idx = trips.indexWhere(
                                          (v) => v.id == currentTrip.id);
                                      if (idx != -1) {
                                        if (!trips[idx].categories.any(
                                            (c) => c.name == newCategory)) {
                                          trips[idx] = trips[idx].copyWith(
                                            categories: [
                                              ...trips[idx].categories,
                                              ExpenseCategory(name: newCategory)
                                            ],
                                          );
                                          await ExpenseGroupStorage.writeTrips(
                                              trips);
                                          onTripAdded();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
