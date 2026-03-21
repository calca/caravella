import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:android_nav_setting/android_nav_setting.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart'
    as gen; // generated
import 'package:caravella_core/caravella_core.dart';
import '../home_constants.dart';
// Removed locale_notifier import after migration
// locale_notifier no longer needed after migration
import 'widgets/widgets.dart';
import '../../manager/history/expenses_history_page.dart';

class HomeCardsSection extends StatefulWidget {
  final VoidCallback onTripAdded;
  final ExpenseGroup? pinnedTrip;
  final List<ExpenseGroup>? initialGroups;
  final bool allArchived;
  final VoidCallback? onTripDeleted;
  final VoidCallback? onTripUpdated;

  const HomeCardsSection({
    super.key,
    required this.onTripAdded,
    this.pinnedTrip,
    this.initialGroups,
    this.allArchived = false,
    this.onTripDeleted,
    this.onTripUpdated,
  });

  @override
  State<HomeCardsSection> createState() => _HomeCardsSectionState();
}

class _HomeCardsSectionState extends State<HomeCardsSection> {
  List<ExpenseGroup> _activeGroups = [];
  ExpenseGroupNotifier? _groupNotifier;
  bool _hasNavigationBar = false;

  @override
  void initState() {
    super.initState();
    // Usa i gruppi iniziali se forniti, altrimenti carica
    _activeGroups = widget.initialGroups ?? [];
    if (widget.initialGroups == null) {
      _loadActiveGroups();
    }
    _initNavSetting();
  }

  Future<void> _initNavSetting() async {
    try {
      final navSetting = AndroidNavSetting();
      final isGesture = await navSetting.isGestureNavigationEnabled();
      if (mounted) {
        setState(() => _hasNavigationBar = !isGesture);
      }
    } catch (e) {
      // best-effort: silently ignore errors (plugin may fail on some devices)
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Setup state listener for efficient updates
    _groupNotifier?.removeListener(_onGroupsUpdated);
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onGroupsUpdated);
  }

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onGroupsUpdated);
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeCardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se il pinnedTrip è cambiato, ricarica i gruppi
    if (oldWidget.pinnedTrip?.id != widget.pinnedTrip?.id) {
      _loadActiveGroups();
    }

    // If parent provided new initialGroups, update local state
    if (widget.initialGroups != null &&
        oldWidget.initialGroups != widget.initialGroups) {
      setState(() {
        _activeGroups = widget.pinnedTrip != null
            ? [
                widget.pinnedTrip!,
                ...widget.initialGroups!.where(
                  (g) => g.id != widget.pinnedTrip!.id,
                ),
              ]
            : widget.initialGroups!;
      });
    }
  }

  void _onGroupsUpdated() {
    final updatedGroupIds = _groupNotifier?.updatedGroupIds ?? [];
    final deletedGroupIds = _groupNotifier?.deletedGroupIds ?? [];

    if (deletedGroupIds.isNotEmpty && mounted) {
      // Remove deleted groups from local list
      setState(() {
        _activeGroups.removeWhere((g) => deletedGroupIds.contains(g.id));
      });

      // If any deleted group was not present locally, ensure a full reload to be safe
      final missingDeleted = deletedGroupIds.where(
        (id) => !_activeGroups.any((g) => g.id == id),
      );
      if (missingDeleted.isNotEmpty) {
        _loadActiveGroups();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onTripDeleted?.call();
      });

      _groupNotifier?.clearDeletedGroups();
      return;
    }

    if (updatedGroupIds.isNotEmpty && mounted) {
      // If any updated group id is not present in the current list, perform full reload
      final missing = updatedGroupIds.where(
        (id) => !_activeGroups.any((g) => g.id == id),
      );
      if (missing.isNotEmpty) {
        _loadActiveGroups();
        return;
      }

      // Otherwise update only affected groups instead of reloading everything
      _updateAffectedGroupsLocally(updatedGroupIds);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onTripUpdated?.call();
      });
    }
  }

  void _handleGroupAdded() {
    widget.onTripAdded();
    _loadActiveGroups();
  }

  void _handleGroupUpdated() {
    widget.onTripUpdated?.call();
    _loadActiveGroups();
  }

  Future<void> _updateAffectedGroupsLocally(
    List<String> updatedGroupIds,
  ) async {
    try {
      bool needsUpdate = false;
      final newGroups = List<ExpenseGroup>.from(_activeGroups);

      for (final groupId in updatedGroupIds) {
        final groupIndex = newGroups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) {
          final updatedGroup = await ExpenseGroupStorageV2.getTripById(groupId);
          if (updatedGroup != null) {
            newGroups[groupIndex] = updatedGroup;
            needsUpdate = true;
          }
        }
      }

      if (needsUpdate && mounted) {
        setState(() {
          _activeGroups = newGroups;
        });
      }
    } catch (e) {
      // Fallback to full reload only on error
      _loadActiveGroups();
    }
  }

  Future<void> _loadActiveGroups() async {
    try {
      final groups = await ExpenseGroupStorageV2.getActiveGroups();
      if (mounted) {
        setState(() {
          // Se c'è un gruppo pinnato, mettiamolo sempre al primo posto
          if (widget.pinnedTrip != null) {
            // Rimuovi il gruppo pinnato dalla lista se è già presente
            final filteredGroups = groups.where(
              (g) => g.id != widget.pinnedTrip!.id,
            );
            // Metti il gruppo pinnato come primo elemento
            _activeGroups = [widget.pinnedTrip!, ...filteredGroups];
          } else {
            _activeGroups = groups;
          }
        });
      }
    } catch (e) {
      // Silently handle error - groups remain empty
      LoggerService.warning(
        'Failed to load active groups: $e',
        name: 'state.home_cards',
      );
    }
  }

  /// Soft reload that updates groups without showing loading state
  /// Used when adding a new group to avoid jarring transitions
  Future<void> _softLoadActiveGroups() async {
    try {
      final groups = await ExpenseGroupStorageV2.getActiveGroups();
      if (mounted) {
        setState(() {
          // Se c'è un gruppo pinnato, mettiamolo sempre al primo posto
          if (widget.pinnedTrip != null) {
            // Rimuovi il gruppo pinnato dalla lista se è già presente
            final filteredGroups = groups.where(
              (g) => g.id != widget.pinnedTrip!.id,
            );
            // Metti il gruppo pinnato come primo elemento
            _activeGroups = [widget.pinnedTrip!, ...filteredGroups];
          } else {
            _activeGroups = groups;
          }
        });
      }
    } catch (e) {
      // Fallback to full reload on error
      _loadActiveGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final topSafeArea = MediaQuery.of(context).padding.top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Safe area for status bar
        SizedBox(height: topSafeArea),

        // Header compatto con altezza fissa
        Padding(
          padding: const EdgeInsets.fromLTRB(
            HomeLayoutConstants.horizontalPadding,
            16.0,
            HomeLayoutConstants.horizontalPadding,
            16.0,
          ),
          child: HomeCardsHeader(localizations: loc, theme: theme),
        ),

        // Content area - fills remaining space dynamically
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeLayoutConstants.horizontalPadding,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _activeGroups.isEmpty
                  ? EmptyGroupsState(
                      localizations: loc,
                      theme: theme,
                      allArchived: widget.allArchived,
                      onGroupAdded: _handleGroupAdded,
                    )
                  : _buildContent(loc, theme),
            ),
          ),
        ),

        // Bottom bar removed from HomeCardsSection; footer handled externally if needed
      ],
    );
  }

  Widget _buildContent(gen.AppLocalizations loc, ThemeData theme) {
    // Safety check - this should never happen due to calling context, but be defensive
    if (_activeGroups.isEmpty) {
      return EmptyGroupsState(
        key: const ValueKey('empty_state'),
        localizations: loc,
        theme: theme,
        allArchived: widget.allArchived,
        onGroupAdded: _handleGroupAdded,
      );
    }

    // Get featured group: use pinned/favorite if available, otherwise first from active groups
    final featuredGroup = widget.pinnedTrip ?? _activeGroups.first;

    // Get remaining groups for carousel (excluding featured)
    final carouselGroups = _activeGroups
        .where((g) => g.id != featuredGroup.id)
        .toList();

    return Column(
      key: const ValueKey('content'),
      children: [
        // Top spacing before featured card
        const SizedBox(height: 8),

        // Featured group card - takes all remaining space
        Expanded(
          child: GroupCard(
            group: featuredGroup,
            localizations: loc,
            theme: theme,
            onGroupUpdated: _handleGroupUpdated,
            onCategoryAdded: () {
              _softLoadActiveGroups();
            },
            isSelected: true,
            selectionProgress: 1.0,
          ),
        ),

        // Section header for "Your Groups" with CTA to history - pinned at bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  loc.your_groups,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ExpesensHistoryPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      loc.see_all,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Carousel with remaining groups - respect bottom safe area
        SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: SizedBox(
            height: HomeLayoutConstants.carouselCardTotalHeight,
            child: HorizontalGroupsList(
              groups: carouselGroups,
              localizations: loc,
              theme: theme,
              onGroupUpdated: _handleGroupUpdated,
              onGroupAdded: _handleGroupAdded,
              onCategoryAdded: () {
                _softLoadActiveGroups();
              },
            ),
          ),
        ),
        // Extra spacing when system navigation bar is present
        if (!_hasNavigationBar) const SizedBox(height: 12),
      ],
    );
  }
}
