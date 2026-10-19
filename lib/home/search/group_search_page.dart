import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../manager/details/pages/expense_group_detail_page.dart';
import '../../manager/details/pages/tabs/usecase/date_range_formatter.dart';
import '../../manager/history/widgets/group_options.dart';

/// Which groups the search covers.
enum GroupSearchStatus { all, active, archived }

/// Search over all groups, in the app's style.
///
/// Before typing (no query, no filters) it suggests where to start: recent
/// searches and the group types present. A filters button opens a sheet
/// (status, favorites, type); active filters stay as removable pills above
/// the results, which are listed in Active / Archived cards with the match
/// highlighted. Tap opens a group, long press its options.
class GroupSearchPage extends StatefulWidget {
  const GroupSearchPage({super.key});

  /// Pushes [GroupSearchPage] on the navigator stack.
  static Future<void> show(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GroupSearchPage()));
  }

  @override
  State<GroupSearchPage> createState() => _GroupSearchPageState();
}

class _GroupSearchPageState extends State<GroupSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _query = '';
  GroupSearchStatus _status = GroupSearchStatus.all;
  bool _favoritesOnly = false;
  ExpenseGroupType? _type;

  bool _loading = true;
  List<ExpenseGroup> _active = [];
  List<ExpenseGroup> _archived = [];
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
    if (PreferencesService.isInitialized) {
      _recent = PreferencesService.instance.search.getRecentGroupSearches();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    try {
      final results = await Future.wait([
        ExpenseGroupStorageV2.getActiveGroups(),
        ExpenseGroupStorageV2.getArchivedGroups(),
      ]);
      if (mounted) {
        setState(() {
          _active = results[0];
          _archived = results[1];
          _loading = false;
        });
      }
    } catch (e) {
      LoggerService.error(
        'Failed to load groups for search',
        name: 'ui.group_search',
        error: e,
      );
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _activeFilters =>
      (_status != GroupSearchStatus.all ? 1 : 0) +
      (_favoritesOnly ? 1 : 0) +
      (_type != null ? 1 : 0);

  bool get _showSuggestions => _query.trim().isEmpty && _activeFilters == 0;

  bool _matches(ExpenseGroup g) {
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty && !g.title.toLowerCase().contains(q)) return false;
    if (_favoritesOnly && !g.pinned) return false;
    if (_type != null && (g.groupType ?? ExpenseGroupType.other) != _type) {
      return false;
    }
    return true;
  }

  List<ExpenseGroup> get _activeResults => _status == GroupSearchStatus.archived
      ? const []
      : _active.where(_matches).toList();

  List<ExpenseGroup> get _archivedResults => _status == GroupSearchStatus.active
      ? const []
      : _archived.where(_matches).toList();

  void _setQuery(String value) {
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _query = value);
  }

  Future<void> _rememberQuery() async {
    if (_query.trim().isEmpty || !PreferencesService.isInitialized) return;
    await PreferencesService.instance.search.addRecentGroupSearch(_query);
    _recent = PreferencesService.instance.search.getRecentGroupSearches();
  }

  Future<void> _open(ExpenseGroup group) async {
    await _rememberQuery();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseGroupDetailPage(trip: group)),
    );
    if (mounted) await _loadGroups();
  }

  Future<void> _onArchiveToggle(String groupId, bool archived) async {
    await Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    ).updateGroupArchive(groupId, archived);
    await _loadGroups();
  }

  String _typeLabel(gen.AppLocalizations gloc, ExpenseGroupType t) =>
      switch (t) {
        ExpenseGroupType.travel => gloc.group_type_travel,
        ExpenseGroupType.personal => gloc.group_type_personal,
        ExpenseGroupType.family => gloc.group_type_family,
        ExpenseGroupType.other => gloc.group_type_other,
      };

  /// Group types present among all groups, with their counts.
  Map<ExpenseGroupType, int> get _typeCounts {
    final counts = <ExpenseGroupType, int>{};
    for (final g in [..._active, ..._archived]) {
      final t = g.groupType ?? ExpenseGroupType.other;
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _openFilters() async {
    _searchFocusNode.unfocus();
    final gloc = gen.AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          void update(VoidCallback change) {
            setState(change);
            setSheet(() {});
          }

          final count = _activeResults.length + _archivedResults.length;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    gloc.filters,
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  PillSection(
                    label: gloc.status_label,
                    pills: [
                      for (final (status, label) in [
                        (GroupSearchStatus.all, gloc.all_groups),
                        (GroupSearchStatus.active, gloc.status_active),
                        (GroupSearchStatus.archived, gloc.status_archived),
                      ])
                        FilterPill(
                          label: label,
                          selected: _status == status,
                          onTap: () => update(() => _status = status),
                        ),
                      FilterPill(
                        icon: Icons.favorite_border_rounded,
                        label: gloc.favorites,
                        selected: _favoritesOnly,
                        onTap: () =>
                            update(() => _favoritesOnly = !_favoritesOnly),
                      ),
                    ],
                  ),
                  PillSection(
                    label: gloc.group_type,
                    pills: [
                      for (final t in _typeCounts.keys)
                        FilterPill(
                          icon: t.icon,
                          label: _typeLabel(gloc, t),
                          selected: _type == t,
                          onTap: () =>
                              update(() => _type = _type == t ? null : t),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(gloc.show_results(count)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;

    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        backgroundColor: s.surfaceContainer,
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, top + 8, 16, 0),
          child: Column(
            children: [
              SearchTopBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: gloc.search_groups,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (_) => _rememberQuery(),
                onFilters: _openFilters,
                activeFilters: _activeFilters,
                filtersTooltip: gloc.filters,
                clearTooltip: gloc.clear,
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : _showSuggestions
                    ? _buildSuggestions(gloc)
                    : _buildResults(gloc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(gen.AppLocalizations gloc) {
    final types = _typeCounts;
    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      children: [
        PillSection(
          label: gloc.recent_searches,
          pills: [
            for (final r in _recent)
              FilterPill(
                icon: Icons.history_rounded,
                label: r,
                onTap: () => _setQuery(r),
              ),
          ],
        ),
        PillSection(
          label: gloc.by_type,
          pills: [
            for (final MapEntry(key: t, value: n) in types.entries)
              FilterPill(
                icon: t.icon,
                label: '${_typeLabel(gloc, t)} · $n',
                onTap: () => setState(() => _type = t),
              ),
            if (_archived.isNotEmpty)
              FilterPill(
                icon: Icons.archive_outlined,
                label: '${gloc.status_archived} · ${_archived.length}',
                onTap: () =>
                    setState(() => _status = GroupSearchStatus.archived),
              ),
            if ([..._active, ..._archived].any((g) => g.pinned))
              FilterPill(
                icon: Icons.favorite_border_rounded,
                label: gloc.favorites,
                onTap: () => setState(() => _favoritesOnly = true),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildResults(gen.AppLocalizations gloc) {
    final active = _activeResults;
    final archived = _archivedResults;
    final pills = <Widget>[
      if (_status != GroupSearchStatus.all)
        FilterPill(
          label: _status == GroupSearchStatus.active
              ? gloc.status_active
              : gloc.status_archived,
          selected: true,
          onRemove: () => setState(() => _status = GroupSearchStatus.all),
        ),
      if (_favoritesOnly)
        FilterPill(
          icon: Icons.favorite_rounded,
          label: gloc.favorites,
          selected: true,
          onRemove: () => setState(() => _favoritesOnly = false),
        ),
      if (_type != null)
        FilterPill(
          icon: _type!.icon,
          label: _typeLabel(gloc, _type!),
          selected: true,
          onRemove: () => setState(() => _type = null),
        ),
    ];

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        if (pills.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: pills),
        if (active.isEmpty && archived.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: EmptyStateView(
              icon: Icons.search_off_outlined,
              message: _query.trim().isEmpty
                  ? gloc.no_search_results
                  : '${gloc.no_search_results} "${_query.trim()}"',
              hint: gloc.try_different_search,
            ),
          ),
        if (active.isNotEmpty)
          SettingsGroup(
            label: '${gloc.status_active} · ${active.length}',
            children: [for (final g in active) _row(gloc, g)],
          ),
        if (archived.isNotEmpty)
          SettingsGroup(
            label: '${gloc.status_archived} · ${archived.length}',
            children: [for (final g in archived) _row(gloc, g)],
          ),
      ],
    );
  }

  Widget _row(gen.AppLocalizations gloc, ExpenseGroup g) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final dates = (g.startDate != null || g.endDate != null)
        ? formatDateRange(
            start: g.startDate,
            end: g.endDate,
            locale: Localizations.localeOf(context),
          )
        : null;
    final people = gloc.participant_count(g.participants.length);
    return Semantics(
      button: true,
      label: [g.title, ?dates, people].join(', '),
      onTap: () => _open(g),
      onLongPress: () => showGroupOptionsSheet(
        context,
        trip: g,
        onArchiveToggle: _onArchiveToggle,
        onDelete: _loadGroups,
        onPin: _loadGroups,
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _open(g),
        onLongPress: () => showGroupOptionsSheet(
          context,
          trip: g,
          onArchiveToggle: _onArchiveToggle,
          onDelete: _loadGroups,
          onPin: _loadGroups,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              GroupIconAvatar(group: g, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightedText(
                      text: g.title,
                      query: _query,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      dates == null ? people : '$dates · $people',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CurrencyDisplay(
                value: g.getTotalExpenses(),
                currency: g.currency,
                valueFontSize: 16,
                currencyFontSize: 11,
                showDecimals: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
