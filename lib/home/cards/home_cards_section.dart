import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart'
    as gen; // generated
import '../../data/expense_group.dart';
import '../../data/expense_group_storage.dart';
import '../../state/expense_group_notifier.dart';
// Removed locale_notifier import after migration
// locale_notifier no longer needed after migration
import 'widgets/widgets.dart';

class HomeCardsSection extends StatefulWidget {
  final VoidCallback onTripAdded;
  final ExpenseGroup? pinnedTrip;

  const HomeCardsSection({
    super.key,
    required this.onTripAdded,
    this.pinnedTrip,
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
    _loadActiveGroups();
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
  }

  void _onGroupsUpdated() {
    final updatedGroupIds = _groupNotifier?.updatedGroupIds ?? [];
    
    if (updatedGroupIds.isNotEmpty && mounted) {
      // Update only affected groups instead of reloading everything
      _updateAffectedGroupsLocally(updatedGroupIds);
    }
  }

  Future<void> _updateAffectedGroupsLocally(List<String> updatedGroupIds) async {
    try {
      bool needsUpdate = false;
      final newGroups = List<ExpenseGroup>.from(_activeGroups);
      
      for (final groupId in updatedGroupIds) {
        final groupIndex = newGroups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) {
          final updatedGroup = await ExpenseGroupStorage.getTripById(groupId);
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
      final groups = await ExpenseGroupStorage.getActiveGroups();
      if (mounted) {
        setState(() {
          // Se c'è un gruppo pinnato, mettiamolo sempre al primo posto
          if (widget.pinnedTrip != null) {
            // Rimuovi il gruppo pinnato dalla lista se è già presente
            final filteredGroups = groups
                .where((g) => g.id != widget.pinnedTrip!.id)
                .toList();
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
                  ? const Center(child: CircularProgressIndicator())
                  : _activeGroups.isEmpty
                  ? EmptyGroupsState(
                      localizations: loc,
                      theme: theme,
                      onGroupAdded: () {
                        widget.onTripAdded();
                        _loadActiveGroups();
                      },
                    )
                  : HorizontalGroupsList(
                      groups: _activeGroups,
                      localizations: loc,
                      theme: theme,
                      onGroupUpdated: () {
                        widget.onTripAdded();
                        _loadActiveGroups();
                      },
                      onCategoryAdded: () {
                        _loadActiveGroups();
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
