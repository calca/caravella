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
import 'cards/widgets/widgets.dart';
import 'home_constants.dart';

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

  // Cached groups to avoid FutureBuilder flash
  List<ExpenseGroup> _activeGroups = [];
  List<ExpenseGroup> _archivedGroups = [];

  @override
  void initState() {
    super.initState();
    // Don't cache the preference value here - we'll determine it after checking storage
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

    // Update first start flag based on whether groups exist
    // If groups exist, it's not first start regardless of preference
    // If no groups exist, respect the preference
    final prefIsFirstStart = PreferencesService.instance.appState
        .isFirstStart();
    final shouldShowWelcome = !hasGroups && prefIsFirstStart;

    // If we determined user has groups but flag says first start,
    // update the preference to reflect reality
    if (hasGroups && prefIsFirstStart) {
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

    // Determine which view to show
    final newViewKey = _isFirstStart
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
    // Use full reload to properly update _isFirstStart based on actual data
    // This ensures the welcome→cards transition happens correctly
    _loadLocaleAndTrip();
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          // Use different transitions based on view type
          final isWelcome = child.key == const ValueKey('welcome');

          if (isWelcome) {
            // Slide in from bottom for welcome screen
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.15),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          } else {
            // Fade transition for cards and loading
            return FadeTransition(opacity: animation, child: child);
          }
        },
        child: _buildContent(gloc),
      ),
    );
  }

  Widget _buildContent(gen.AppLocalizations gloc) {
    if (_loading) {
      // Show skeleton loader during initial load for better UX
      // Uses same layout as HomeCardsSection with skeleton only for carousel
      return SafeArea(
        key: const ValueKey('loading'),
        child: _buildSkeletonLayout(gloc),
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
    if (_activeGroups.isNotEmpty) {
      return RefreshIndicator(
        key: const ValueKey('cards_active'),
        onRefresh: _handleUserRefresh,
        child: SafeArea(
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
        ),
      );
    }

    if (_archivedGroups.isNotEmpty) {
      return RefreshIndicator(
        key: const ValueKey('cards_archived'),
        onRefresh: _handleUserRefresh,
        child: SafeArea(
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

  /// Builds a skeleton layout matching HomeCardsSection structure
  /// Header and bottom bar are real, only content is skeleton
  Widget _buildSkeletonLayout(gen.AppLocalizations gloc) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topSafeArea = mediaQuery.padding.top;

    // Same height calculations as HomeCardsSection
    const headerHeight = HomeLayoutConstants.headerHeight;
    const headerPaddingVertical = 32.0; // 16 top + 16 bottom padding
    final bottomBarHeight =
        screenHeight * HomeLayoutConstants.bottomBarHeightRatio;
    final contentHeight =
        screenHeight -
        headerHeight -
        headerPaddingVertical -
        bottomBarHeight -
        topSafeArea;

    // Featured card takes 60% of content height
    final featuredCardHeight =
        contentHeight * HomeLayoutConstants.featuredCardHeightRatio;
    // Carousel takes 40% of content height
    final carouselHeight =
        contentHeight * HomeLayoutConstants.carouselHeightRatio;

    return SizedBox(
      height: screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Safe area for status bar
          SizedBox(height: topSafeArea),

          // Real header - shows immediately
          Padding(
            padding: const EdgeInsets.fromLTRB(
              HomeLayoutConstants.horizontalPadding,
              16.0,
              HomeLayoutConstants.horizontalPadding,
              16.0,
            ),
            child: SizedBox(
              height: headerHeight,
              child: HomeCardsHeader(localizations: gloc, theme: theme),
            ),
          ),

          // Skeleton content - featured card + carousel
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeLayoutConstants.horizontalPadding,
            ),
            child: SizedBox(
              height: contentHeight,
              child: Column(
                children: [
                  // Featured card skeleton
                  SizedBox(
                    height: featuredCardHeight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: HomeLayoutConstants.sectionSpacing,
                      ),
                      child: FeaturedCardSkeleton(theme: theme),
                    ),
                  ),

                  // Carousel skeleton
                  SizedBox(
                    height: carouselHeight,
                    child: CarouselSkeletonLoader(theme: theme),
                  ),
                ],
              ),
            ),
          ),

          // Real bottom bar - shows immediately
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeLayoutConstants.horizontalPadding,
            ),
            child: SimpleBottomBar(localizations: gloc, theme: theme),
          ),
        ],
      ),
    );
  }
}
