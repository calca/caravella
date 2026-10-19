import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart'
    as gen; // generated
import 'package:caravella_core/caravella_core.dart';
import '../home_constants.dart';
import '../navigation_helpers.dart';
import '../../main/app_shell.dart';
import 'widgets/group_quick_actions.dart';
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
  ExpenseGroupNotifier? _groupNotifier;

  @override
  void initState() {
    super.initState();
    // Usa i gruppi iniziali se forniti, altrimenti carica
    _activeGroups = widget.initialGroups ?? [];
    if (widget.initialGroups == null) {
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

  /// The featured group: the pinned one, else the first active group.
  ExpenseGroup? get _featuredGroup =>
      _activeGroups.isEmpty ? null : (widget.pinnedTrip ?? _activeGroups.first);

  /// Registers Home's round button next to the floating navigation: a new
  /// expense in the featured group, or a new group when there is none.
  void _registerPrimaryAction(gen.AppLocalizations loc) {
    final shell = AppShellScope.maybeOf(context);
    if (shell == null) return;
    final featured = _featuredGroup;
    shell.setPrimaryAction(
      AppTab.home,
      featured == null
          ? FloatingNavAction(
              icon: Icons.create_new_folder_outlined,
              label: loc.create_new_group,
              onPressed: () => NavigationHelpers.openGroupCreationWithCallback(
                context,
                onGroupAdded: ([_]) => _handleGroupAdded(),
              ),
            )
          : FloatingNavAction(
              icon: Icons.add_rounded,
              label: loc.new_expense_in_group(featured.title),
              onPressed: () => AddExpenseController(
                group: featured,
                onExpenseAdded: _handleGroupUpdated,
                onCategoryAdded: _softLoadActiveGroups,
              ).showAddExpenseSheet(context, featured),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final topSafeArea = MediaQuery.paddingOf(context).top;
    _registerPrimaryAction(loc);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        HomeLayoutConstants.horizontalPadding,
        16.0,
        HomeLayoutConstants.horizontalPadding,
        16.0,
      ),
      child: HomeCardsHeader(localizations: loc, theme: theme),
    );

    final featured = _featuredGroup;
    if (featured == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSafeArea),
          header,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                HomeLayoutConstants.horizontalPadding,
                0,
                HomeLayoutConstants.horizontalPadding,
                FloatingNavBar.reservedHeight,
              ),
              child: EmptyGroupsState(
                localizations: loc,
                theme: theme,
                allArchived: widget.allArchived,
                onGroupAdded: _handleGroupAdded,
              ),
            ),
          ),
        ],
      );
    }

    // The featured card fills the screen above the floating navigation; the
    // quick actions sit below it and are reached by scrolling. All groups
    // live in the Groups tab, so there is no carousel any more (#529, #530).
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = math.max(
          HomeLayoutConstants.minFeaturedCardHeight,
          constraints.maxHeight -
              topSafeArea -
              HomeLayoutConstants.headerHeight -
              FloatingNavBar.reservedHeight -
              bottomSafeArea,
        );
        return Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topSafeArea),
                  header,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HomeLayoutConstants.horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: cardHeight,
                          child: GroupCard(
                            group: featured,
                            localizations: loc,
                            theme: theme,
                            onGroupUpdated: _handleGroupUpdated,
                            onCategoryAdded: _softLoadActiveGroups,
                            isSelected: true,
                            selectionProgress: 1.0,
                            showAddButton:
                                AppShellScope.maybeOf(context) == null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GroupQuickActions(group: featured),
                        SizedBox(
                          height:
                              FloatingNavBar.reservedHeight +
                              bottomSafeArea +
                              24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Opaque strip behind the status bar so scrolled content doesn't
            // run under the clock.
            Container(
              height: topSafeArea,
              color: theme.colorScheme.surfaceContainer,
            ),
          ],
        );
      },
    );
  }
}
