import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import '../main/route_observer.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:play_store_updates/play_store_updates.dart';
import '../settings/update/app_update_localizations.dart';
import 'welcome/home_welcome_section.dart';
import 'cards/home_cards_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  ExpenseGroup? _pinnedTrip;
  bool _loading = true;
  ExpenseGroupNotifier? _groupNotifier;
  bool _refreshing = false;
  bool _updateCheckPerformed = false;
  bool _isFirstStart = true; // Cache preference value

  @override
  void initState() {
    super.initState();
    // Cache the preference value to avoid repeated reads during builds
    _isFirstStart = PreferencesService.instance.appState.isFirstStart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocaleAndTrip();
      _performUpdateCheckIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);

    // Rimuovi il listener precedente se esiste
    _groupNotifier?.removeListener(_onGroupUpdated);

    // Ottieni il nuovo notifier e aggiungi il listener
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onGroupUpdated);
  }

  @override
  void dispose() {
    // Rimuovi il listener in modo sicuro
    _groupNotifier?.removeListener(_onGroupUpdated);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refresh();
  }

  void _onGroupUpdated() {
    final updatedGroupIds = _groupNotifier?.updatedGroupIds ?? [];

    if (updatedGroupIds.isNotEmpty && mounted) {
      // Usa state-based updates invece di ricaricare tutto
      setState(() {
        // Trigger rebuild of the UI with updated state
        // La UI si aggiornerà automaticamente grazie al Consumer pattern
      });

      // Aggiorna solo il pinned trip se necessario
      _updatePinnedTripIfNeeded(updatedGroupIds);

      // Pulisci la lista degli aggiornamenti
      _groupNotifier?.clearUpdatedGroups();
      final event = _groupNotifier?.consumeLastEvent();
      if (event == 'expense_added') {
        final gloc = gen.AppLocalizations.of(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.show(
            context,
            gloc.expense_added_success,
            type: ToastType.success,
          );
        });
      }
    }
  }

  Future<void> _updatePinnedTripIfNeeded(List<String> updatedGroupIds) async {
    if (_pinnedTrip != null && updatedGroupIds.contains(_pinnedTrip!.id)) {
      try {
        final updatedPinnedTrip = await ExpenseGroupStorageV2.getTripById(
          _pinnedTrip!.id,
        );
        if (mounted && updatedPinnedTrip != null) {
          setState(() {
            _pinnedTrip = updatedPinnedTrip;
          });
        }
      } catch (e) {
        // Fallback to full reload only if there's an error
        _loadLocaleAndTrip();
      }
    }
  }

  Future<void> _loadLocaleAndTrip() async {
    if (!_refreshing) {
      setState(() {
        _loading = true;
      });
    }
    final pinnedTrip = await ExpenseGroupStorageV2.getPinnedTrip();
    if (!mounted) return;
    setState(() {
      _pinnedTrip = pinnedTrip;
      _loading = false;
      _refreshing = false;
    });

    // Update shortcuts after data is loaded
    PlatformShortcutsManager.updateShortcuts();
  }

  Future<void> _performUpdateCheckIfNeeded() async {
    // Only check once per app session
    if (_updateCheckPerformed) return;
    _updateCheckPerformed = true;

    // Wait for the page to be fully rendered
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // Perform the automatic update check
    final loc = gen.AppLocalizations.of(context);
    await checkAndShowUpdateIfNeeded(
      context,
      AppUpdateLocalizations(loc),
      (context, {required title, required child}) =>
          GroupBottomSheetScaffold(title: title, child: child),
    );
  }

  /// Soft refresh that only updates the pinned trip without showing loading state
  Future<void> _softRefresh() async {
    final pinnedTrip = await ExpenseGroupStorageV2.getPinnedTrip();
    if (!mounted) return;
    setState(() {
      _pinnedTrip = pinnedTrip;
    });
  }

  void _refresh() => _softRefresh();

  Future<void> _handleUserRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _loadLocaleAndTrip();
    if (mounted) {
      AppToast.show(
        context,
        gen.AppLocalizations.of(context).data_refreshed,
        type: ToastType.info,
      );
    }
  }

  void _handleTripAdded() {
    final gloc = gen.AppLocalizations.of(context);
    // Update cached preference value since user just added a group
    setState(() {
      _isFirstStart = false;
    });
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppToast.show(context, gloc.group_added_success, type: ToastType.success);
    });
  }

  void _handleTripDeleted() {
    final gloc = gen.AppLocalizations.of(context);
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppToast.show(
        context,
        gloc.group_deleted_success,
        type: ToastType.success,
      );
    });
  }

  void _handleTripUpdated() {
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? Semantics(
              liveRegion: true,
              label: gloc.accessibility_loading_groups,
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: gloc.accessibility_loading_your_groups,
                ),
              ),
            )
          : !_isFirstStart
              ? RefreshIndicator(
                  onRefresh: _handleUserRefresh,
                  child: FutureBuilder<List<List<ExpenseGroup>>>(
                    future: Future.wait<List<ExpenseGroup>>([
                      ExpenseGroupStorageV2.getActiveGroups(),
                      ExpenseGroupStorageV2.getArchivedGroups(),
                    ]),
                    builder: (context, snapshot) {
                      final active =
                          snapshot.data != null && snapshot.data!.isNotEmpty
                          ? snapshot.data![0]
                          : <ExpenseGroup>[];
                      final archived =
                          snapshot.data != null && snapshot.data!.length > 1
                          ? snapshot.data![1]
                          : <ExpenseGroup>[];

                      // Show HomeCardsSection when there are active groups.
                      // If active is empty but archived groups exist, still show HomeCardsSection
                      // with an empty list so the UI renders only the add-card.
                      if (active.isNotEmpty) {
                        return SafeArea(
                          child: Semantics(
                            label: gloc.accessibility_groups_list,
                            child: HomeCardsSection(
                              initialGroups: active,
                              onTripAdded: _handleTripAdded,
                              onTripDeleted: _handleTripDeleted,
                              onTripUpdated: _handleTripUpdated,
                              pinnedTrip: _pinnedTrip,
                              allArchived: false,
                            ),
                          ),
                        );
                      }

                      // If no active groups but there are archived groups, enter home with empty cards
                      if (archived.isNotEmpty) {
                        return SafeArea(
                          child: Semantics(
                            label: gloc.accessibility_groups_list,
                            child: HomeCardsSection(
                              initialGroups: <ExpenseGroup>[],
                              onTripAdded: _handleTripAdded,
                              onTripDeleted: _handleTripDeleted,
                              onTripUpdated: _handleTripUpdated,
                              pinnedTrip: _pinnedTrip,
                              allArchived: true,
                            ),
                          ),
                        );
                      } else {
                        return Semantics(
                          label: gloc.accessibility_welcome_screen,
                          child: HomeWelcomeSection(
                            onTripAdded: () {
                              _handleTripAdded();
                            },
                          ),
                        );
                      }
                    },
                  ),
                )
              : Semantics(
                  label: gloc.accessibility_welcome_screen,
                  child: HomeWelcomeSection(
                    onTripAdded: () {
                      _handleTripAdded();
                    },
                  ),
                ),
    );
  }
}
