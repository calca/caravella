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
  bool _dataLoaded = false;
  ExpenseGroupNotifier? _groupNotifier;
  bool _refreshing = false;
  bool _updateCheckPerformed = false;
  bool _isFirstStart = true; // Cache preference value

  // Cached groups to avoid FutureBuilder flash
  List<ExpenseGroup> _activeGroups = [];
  List<ExpenseGroup> _archivedGroups = [];

  @override
  void initState() {
    super.initState();
    // Optimistic first-start check
    // PreferencesService is initialized in main() before app runs, so safe to access
    // SharedPreferences caches values in memory, so synchronous read is non-blocking
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
      // Consume event but don't show toast for expense_added from home page
      _groupNotifier?.consumeLastEvent();
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

  /// Determines whether the welcome screen should be shown based on actual data and preferences.
  /// Returns true only if there are no groups AND the preference indicates first start.
  /// This data-driven approach ensures groups are always shown if they exist,
  /// regardless of preference state (handles edge cases like preference update failures).
  ///
  /// Also returns the preference value for potential auto-correction logic.
  ({bool shouldShowWelcome, bool isFirstStartFromPrefs})
  _shouldShowWelcomeScreen(bool hasGroups) {
    final prefValue = PreferencesService.instance.appState.isFirstStart();
    return (
      shouldShowWelcome: !hasGroups && prefValue,
      isFirstStartFromPrefs: prefValue,
    );
  }

  Future<void> _loadLocaleAndTrip() async {
    // Load pinned trip and groups in parallel
    final results = await Future.wait([
      ExpenseGroupStorageV2.getPinnedTrip(),
      ExpenseGroupStorageV2.getActiveGroups(),
      ExpenseGroupStorageV2.getArchivedGroups(),
    ]);

    final pinnedTrip = results[0] as ExpenseGroup?;
    final activeGroups = results[1] as List<ExpenseGroup>;
    final archivedGroups = results[2] as List<ExpenseGroup>;
    final hasGroups = activeGroups.isNotEmpty || archivedGroups.isNotEmpty;

    if (!mounted) return;

    // Determine if we should show welcome screen based on data and preferences
    final (:shouldShowWelcome, :isFirstStartFromPrefs) =
        _shouldShowWelcomeScreen(hasGroups);

    // If we determined user has groups but flag says first start,
    // update the preference to reflect reality
    if (hasGroups && isFirstStartFromPrefs) {
      LoggerService.info(
        'Detected existing groups but isFirstStart=true, correcting preference',
        name: 'state.home',
      );
      await PreferencesService.instance.appState.setIsFirstStart(false);
    }

    // Determine which view to show for AnimatedSwitcher
    final newViewKey = shouldShowWelcome
        ? 'welcome'
        : activeGroups.isNotEmpty
        ? 'cards_active'
        : archivedGroups.isNotEmpty
        ? 'cards_archived'
        : 'welcome';

    LoggerService.debug(
      'View state: isFirstStart=$shouldShowWelcome, active=${activeGroups.length}, archived=${archivedGroups.length}, viewKey=$newViewKey',
      name: 'state.home',
    );

    setState(() {
      _pinnedTrip = pinnedTrip;
      _activeGroups = activeGroups;
      _archivedGroups = archivedGroups;
      _isFirstStart = shouldShowWelcome;
      _dataLoaded = true;
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

  /// Soft refresh that only updates the pinned trip and groups without showing loading state
  Future<void> _softRefresh() async {
    final results = await Future.wait([
      ExpenseGroupStorageV2.getPinnedTrip(),
      ExpenseGroupStorageV2.getActiveGroups(),
      ExpenseGroupStorageV2.getArchivedGroups(),
    ]);

    if (!mounted) return;

    final pinnedTrip = results[0] as ExpenseGroup?;
    final activeGroups = results[1] as List<ExpenseGroup>;
    final archivedGroups = results[2] as List<ExpenseGroup>;
    final hasGroups = activeGroups.isNotEmpty || archivedGroups.isNotEmpty;

    // Determine if we should show welcome screen based on data and preferences
    final shouldShowWelcome = _shouldShowWelcomeScreen(
      hasGroups,
    ).shouldShowWelcome;

    // Determine which view to show
    final newViewKey = shouldShowWelcome
        ? 'welcome'
        : activeGroups.isNotEmpty
        ? 'cards_active'
        : archivedGroups.isNotEmpty
        ? 'cards_archived'
        : 'welcome';

    LoggerService.debug(
      'Soft refresh: active=${activeGroups.length}, archived=${archivedGroups.length}, viewKey=$newViewKey',
      name: 'state.home',
    );

    setState(() {
      _pinnedTrip = pinnedTrip;
      _activeGroups = activeGroups;
      _archivedGroups = archivedGroups;
      _isFirstStart = shouldShowWelcome;
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

  Future<void> _handleTripAdded() async {
    final gloc = gen.AppLocalizations.of(context);
    // Use full reload to properly update _isFirstStart based on actual data
    // This ensures the welcome→cards transition happens correctly
    await _loadLocaleAndTrip();
    if (!mounted) return;
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

    final scaffoldBody = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          // Smooth fade transition with slight scale for polish
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            ),
            child: child,
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          // Stack children during transition for seamless crossfade
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _buildContent(gloc),
      ),
    );

    // Use surfaceContainer system UI when NOT in welcome section
    if (!_isFirstStart) {
      return AppSystemUI.surfaceContainer(
        context: context,
        child: scaffoldBody,
      );
    }

    // Welcome section handles its own system UI
    return scaffoldBody;
  }

  Widget _buildContent(gen.AppLocalizations gloc) {
    // Show welcome screen if first start or no data loaded yet and first start preference
    if (_isFirstStart && !_dataLoaded) {
      // Show welcome immediately for first-time users (no loading state)
      return Semantics(
        key: const ValueKey('welcome'),
        label: gloc.accessibility_welcome_screen,
        child: HomeWelcomeSection(onTripAdded: _handleTripAdded),
      );
    }

    if (_isFirstStart) {
      return Semantics(
        key: const ValueKey('welcome'),
        label: gloc.accessibility_welcome_screen,
        child: HomeWelcomeSection(onTripAdded: _handleTripAdded),
      );
    }

    // Show cards section - either with active groups or empty (when all archived)
    // Note: No SafeArea here - HomeCardsSection handles topSafeArea internally
    if (_activeGroups.isNotEmpty) {
      return RefreshIndicator(
        key: const ValueKey('cards_active'),
        onRefresh: _handleUserRefresh,
        child: Semantics(
          label: gloc.accessibility_groups_list,
          child: HomeCardsSection(
            initialGroups: _activeGroups,
            onTripAdded: _handleTripAdded,
            onTripDeleted: _handleTripDeleted,
            onTripUpdated: _handleTripUpdated,
            pinnedTrip: _pinnedTrip,
            allArchived: false,
          ),
        ),
      );
    }

    // Note: No SafeArea here - HomeCardsSection handles topSafeArea internally
    if (_archivedGroups.isNotEmpty) {
      return RefreshIndicator(
        key: const ValueKey('cards_archived'),
        onRefresh: _handleUserRefresh,
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
    }

    // No groups at all - show welcome (this handles edge case of all groups deleted)
    return Semantics(
      key: const ValueKey('welcome'),
      label: gloc.accessibility_welcome_screen,
      child: HomeWelcomeSection(onTripAdded: _handleTripAdded),
    );
  }
}
