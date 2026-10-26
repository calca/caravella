import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../group/pages/group_creation_wizard_page.dart';
import 'widgets/expense_group_empty_states.dart';
import 'widgets/group_photo_card.dart';
import '../../home/search/group_search_page.dart';
import '../../main/app_shell.dart';
import '../details/pages/section_swipe.dart';

class ExpesensHistoryPage extends StatefulWidget {
  const ExpesensHistoryPage({super.key});

  @override
  State<ExpesensHistoryPage> createState() => _ExpesensHistoryPageState();
}

class _ExpesensHistoryPageState extends State<ExpesensHistoryPage> {
  List<ExpenseGroup> _activeTrips = [];
  List<ExpenseGroup> _archivedTrips = [];
  List<ExpenseGroup> _filteredActiveTrips = [];
  List<ExpenseGroup> _filteredArchivedTrips = [];
  bool _loading = true;
  // Scroll + FAB state
  late final ScrollController _scrollController;
  bool _fabVisible = true;
  Timer? _fabIdleTimer;
  bool _showArchived = false;
  // Horizontal travel of the current drag, for swiping Active <-> Archived.
  double _swipeDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  ExpenseGroupNotifier? _groupNotifier;

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onNotifierChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabIdleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Wire notifier listener for external updates/deletes
    _groupNotifier?.removeListener(_onNotifierChanged);
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _seenRevision = _groupNotifier?.revision ?? 0;
    _groupNotifier?.addListener(_onNotifierChanged);
  }

  /// Last [ExpenseGroupNotifier.revision] this page loaded.
  int _seenRevision = 0;

  void _onNotifierChanged() async {
    // Compare revisions rather than reading the updated/deleted queues: in
    // the app shell Home is alive too and clears them first.
    final revision = _groupNotifier?.revision ?? 0;
    if (revision != _seenRevision && mounted) {
      _seenRevision = revision;
      // Reload the trips to reflect external changes (deletions/updates)
      await _loadTrips();
    }
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      // Load both active and archived trips simultaneously
      final activeTrips = await ExpenseGroupStorageV2.getActiveGroups();
      final archivedTrips = await ExpenseGroupStorageV2.getArchivedGroups();

      if (mounted) {
        setState(() {
          _activeTrips = activeTrips;
          _archivedTrips = archivedTrips;
          _filteredActiveTrips = _applyFilter(_activeTrips);
          _filteredArchivedTrips = _applyFilter(_archivedTrips);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(
          context,
          'Errore nel caricamento dei gruppi',
          type: ToastType.error,
        );
      }
    }
  }

  List<ExpenseGroup> _applyFilter(List<ExpenseGroup> trips) {
    // Sort: pinned groups first, then the rest
    final filtered = List<ExpenseGroup>.from(trips);
    filtered.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return 0;
    });
    return filtered;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_fabVisible && mounted) setState(() => _fabVisible = false);
      _fabIdleTimer?.cancel();
      _fabIdleTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted && !_fabVisible) setState(() => _fabVisible = true);
      });
    } else if (direction == ScrollDirection.forward) {
      if (!_fabVisible && mounted) setState(() => _fabVisible = true);
      _fabIdleTimer?.cancel();
    }
  }

  Future<void> _createGroup() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GroupCreationWizardPage()),
    );
    // The wizard returns the new group's id.
    if (result != null) await _loadTrips();
  }

  Widget _buildAnimatedFab(gen.AppLocalizations gloc) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      offset: _fabVisible ? Offset.zero : const Offset(0.3, 1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        opacity: _fabVisible ? 1 : 0,
        child: AddFab(
          heroTag: 'add-group-fab',
          onPressed: _createGroup,
          tooltip: gloc.add_trip,
        ),
      ),
    );
  }

  // Handler for archive toggle from the card: persist archive state and reload list.
  Future<void> _onArchiveToggle(String groupId, bool archived) async {
    // Persist archive state using the notifier (handles storage + shortcuts)
    await Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    ).updateGroupArchive(groupId, archived);
    // Small delay to allow storage to settle, then reload the list
    await Future.delayed(const Duration(milliseconds: 50));
    await _loadTrips();
  }

  /// Favorite group as a wide card on top (active groups only), the others
  /// as a two-column grid of photo tiles.
  List<Widget> _buildGroupSlivers(List<ExpenseGroup> trips, double bottom) {
    if (_loading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      ];
    }
    if (trips.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
            child: Align(
              alignment: Alignment.topCenter,
              child: ExpenseGroupEmptyStates(
                searchQuery: '',
                periodFilter: _showArchived ? 'archived' : 'active',
                onTripAdded: _createGroup,
              ),
            ),
          ),
        ),
      ];
    }

    final favorite = _showArchived
        ? null
        : trips.where((t) => t.pinned).firstOrNull;
    final others = trips.where((t) => t != favorite).toList();
    return [
      if (favorite != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              // Room for the photo above the text it melts into.
              height: 196,
              child: GroupPhotoCard(
                group: favorite,
                wide: true,
                onArchiveToggle: _onArchiveToggle,
                onChanged: _loadTrips,
              ),
            ),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => GroupPhotoCard(
              group: others[i],
              onArchiveToggle: _onArchiveToggle,
              onChanged: _loadTrips,
            ),
            childCount: others.length,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // As the Groups tab of the app shell, "new group" is the round button
    // next to the floating navigation; pushed on its own, the page keeps
    // its FAB and a back button.
    final shell = AppShellScope.maybeOf(context);
    shell?.setPrimaryAction(
      AppTab.groups,
      FloatingNavAction(
        icon: Icons.create_new_folder_outlined,
        label: gloc.create_new_group,
        onPressed: _createGroup,
      ),
    );
    final top = MediaQuery.paddingOf(context).top;
    final bottom = shell != null
        ? FloatingNavBar.reservedHeight +
              MediaQuery.paddingOf(context).bottom +
              16
        : 100.0;
    final trips = _showArchived ? _filteredArchivedTrips : _filteredActiveTrips;

    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        floatingActionButton: shell == null ? _buildAnimatedFab(gloc) : null,
        body: Stack(
          children: [
            // Swipe between Active and Archived, like the sections of the
            // group page; the pill control follows.
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (_) => _swipeDistance = 0,
              onHorizontalDragUpdate: (d) => _swipeDistance += d.delta.dx,
              onHorizontalDragEnd: (d) {
                final next = sectionAfterSwipe(
                  current: _showArchived ? 1 : 0,
                  count: 2,
                  distance: _swipeDistance,
                  velocity: d.primaryVelocity ?? 0,
                  rtl: Directionality.of(context) == TextDirection.rtl,
                );
                if (next != null) setState(() => _showArchived = next == 1);
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: top + 16)),
                  // Same header language as Home: count above a large title,
                  // search in a raised circle like Home's settings button.
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          if (shell == null) ...[
                            const RoundBackButton(),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gloc.groups_active_count(_activeTrips.length),
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Semantics(
                                  header: true,
                                  child: Text(
                                    gloc.nav_groups,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: scheme.raisedSurface,
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.search_rounded),
                              color: scheme.onSurface,
                              tooltip: gloc.show_search,
                              onPressed: () async {
                                await GroupSearchPage.show(context);
                                // The user may have changed pin/archive state
                                // from the search page.
                                if (mounted) await _loadTrips();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: PillSegmentedControl(
                          labels: [
                            '${gloc.status_active} · ${_activeTrips.length}',
                            '${gloc.status_archived} · ${_archivedTrips.length}',
                          ],
                          selectedIndex: _showArchived ? 1 : 0,
                          onChanged: (i) =>
                              setState(() => _showArchived = i == 1),
                        ),
                      ),
                    ),
                  ),
                  ..._buildGroupSlivers(trips, bottom),
                ],
              ),
            ),
            // Edge to edge: scrolled content fades under the clock.
            StatusBarFade(color: scheme.surfaceContainer),
          ],
        ),
      ),
    );
  }
}
