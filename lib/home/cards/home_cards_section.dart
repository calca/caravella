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
                  ? CarouselSkeletonLoader(theme: theme)
                  : _activeGroups.isEmpty
                  ? EmptyGroupsState(
                      localizations: loc,
                      theme: theme,
                      allArchived: widget.allArchived,
                      onGroupAdded: _handleGroupAdded,
                    )
                  : HorizontalGroupsList(
                      groups: _activeGroups,
                      localizations: loc,
                      theme: theme,
                      onGroupUpdated: _handleGroupUpdated,
                      onGroupAdded: _handleGroupAdded,
                      onCategoryAdded: () {
                        _softLoadActiveGroups();
                      },
                    ),
            ),

            // Bottom bar semplificata d
            SimpleBottomBar(localizations: loc, theme: theme),
          ],
        ),
      ),
    );
  }
}
