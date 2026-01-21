import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart'
    as gen; // generated
import 'package:caravella_core/caravella_core.dart';
// Removed locale_notifier import after migration
// locale_notifier no longer needed after migration
import 'widgets/widgets.dart';

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
  bool _loading = true;
  ExpenseGroupNotifier? _groupNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.initialGroups != null) {
      _activeGroups = widget.initialGroups!;
      _loading = false;
    } else {
      _loadActiveGroups();
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

    // If parent provided new initialGroups (e.g., FutureBuilder resolved again), update local state
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
        _loading = false;
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
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Altezze delle varie sezioni
    final headerHeight = screenHeight / 6;
    final bottomBarHeight = screenHeight / 6;
    final contentHeight = screenHeight - headerHeight - bottomBarHeight;

    return SizedBox(
      height: screenHeight, // Fornisce un vincolo di altezza definito
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header con avatar e saluto dinamico
            SizedBox(
              height: headerHeight,
              child: HomeCardsHeader(localizations: loc, theme: theme),
            ),

            // Content area - riempie lo spazio tra header e bottom bar
            SizedBox(
              height: contentHeight,
              child: _loading
                  ? _buildSkeletonContent(theme, contentHeight)
                  : _activeGroups.isEmpty
                  ? EmptyGroupsState(
                      localizations: loc,
                      theme: theme,
                      allArchived: widget.allArchived,
                      onGroupAdded: _handleGroupAdded,
                    )
                  : _buildContent(
                      loc,
                      theme,
                      contentHeight,
                    ),
            ),

            // Bottom bar semplificata d
            SimpleBottomBar(localizations: loc, theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    gen.AppLocalizations loc,
    ThemeData theme,
    double contentHeight,
  ) {
    // Safety check - this should never happen due to calling context, but be defensive
    if (_activeGroups.isEmpty) {
      return EmptyGroupsState(
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

    // Featured card takes 60% of content height
    final featuredCardHeight = contentHeight * 0.6;
    // Carousel takes 40% of content height
    final carouselHeight = contentHeight * 0.4;

    return Column(
      children: [
        // Featured group card
        SizedBox(
          height: featuredCardHeight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
        ),

        // Carousel with remaining groups
        if (carouselGroups.isNotEmpty)
          SizedBox(
            height: carouselHeight,
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
        
        // Show "Add Group" option in the carousel area if only featured group exists
        if (carouselGroups.isEmpty)
          SizedBox(
            height: carouselHeight,
            child: HorizontalGroupsList(
              groups: const [], // Empty list, will show only the "add new" card
              localizations: loc,
              theme: theme,
              onGroupUpdated: _handleGroupUpdated,
              onGroupAdded: _handleGroupAdded,
              onCategoryAdded: () {
                _softLoadActiveGroups();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonContent(ThemeData theme, double contentHeight) {
    // Featured card takes 60% of content height
    final featuredCardHeight = contentHeight * 0.6;
    // Carousel takes 40% of content height
    final carouselHeight = contentHeight * 0.4;

    return Column(
      children: [
        // Featured card skeleton
        SizedBox(
          height: featuredCardHeight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeaturedCardSkeleton(theme: theme),
          ),
        ),
        
        // Carousel skeleton
        SizedBox(
          height: carouselHeight,
          child: CarouselSkeletonLoader(theme: theme),
        ),
      ],
    );
  }
}

/// Skeleton widget for the featured card shown during loading
class _FeaturedCardSkeleton extends StatefulWidget {
  final ThemeData theme;

  const _FeaturedCardSkeleton({required this.theme});

  @override
  State<_FeaturedCardSkeleton> createState() => _FeaturedCardSkeletonState();
}

class _FeaturedCardSkeletonState extends State<_FeaturedCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final colorScheme = widget.theme.colorScheme;
        
        // Create shimmer gradient
        final shimmerGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          stops: [
            (_shimmerController.value - 0.3).clamp(0.0, 1.0),
            _shimmerController.value,
            (_shimmerController.value + 0.3).clamp(0.0, 1.0),
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: shimmerGradient,
                ),
              ),
              // Card content skeleton
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    _SkeletonBox(
                      width: 200,
                      height: 28,
                      borderRadius: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle skeleton
                    _SkeletonBox(
                      width: 160,
                      height: 20,
                      borderRadius: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                    const Spacer(),
                    // Stats skeleton at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SkeletonBox(
                              width: 100,
                              height: 16,
                              borderRadius: 8,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SkeletonBox(
                              width: 120,
                              height: 24,
                              borderRadius: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ],
                        ),
                        _SkeletonBox(
                          width: 64,
                          height: 64,
                          borderRadius: 32,
                          color: colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple skeleton box widget for featured card
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
