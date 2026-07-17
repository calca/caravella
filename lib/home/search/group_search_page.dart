import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../manager/history/widgets/swipeable_expense_group_card.dart';

/// Full-screen Gmail-style search page for groups.
///
/// Features:
/// - Text field in the AppBar (autofocused) for real-time filtering
/// - Shows all groups (active + archived) filtered by title
/// - Empty state when no results match the query
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

  String _searchQuery = '';
  bool _loading = true;
  List<ExpenseGroup> _allGroups = [];
  List<ExpenseGroup> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
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
      final active = results[0];
      final archived = results[1];
      if (mounted) {
        setState(() {
          _allGroups = [...active, ...archived];
          _filteredGroups = _applyFilter(_allGroups);
          _loading = false;
        });
      }
    } catch (e) {
      LoggerService.error(
        'Failed to load groups for search',
        name: 'ui.group_search',
        error: e,
      );
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<ExpenseGroup> _applyFilter(List<ExpenseGroup> groups) {
    if (_searchQuery.isEmpty) return groups;
    final query = _searchQuery.toLowerCase();
    return groups.where((g) => g.title.toLowerCase().contains(query)).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _filteredGroups = _applyFilter(_allGroups);
    });
  }

  Future<void> _onArchiveToggle(String groupId, bool archived) async {
    await Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    ).updateGroupArchive(groupId, archived);
    await Future.delayed(const Duration(milliseconds: 50));
    await _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return Scaffold(
      appBar: SearchAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: gloc.search_groups,
        onChanged: _onSearchChanged,
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: gloc.clear,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _filteredGroups.isEmpty
          ? EmptyStateView(
              icon: _searchQuery.isEmpty
                  ? Icons.search_outlined
                  : Icons.search_off_outlined,
              message: _searchQuery.isEmpty
                  ? gloc.search_groups
                  : '${gloc.no_search_results} "$_searchQuery"',
              hint: _searchQuery.isEmpty ? null : gloc.try_different_search,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              itemCount: _filteredGroups.length,
              itemBuilder: (context, index) {
                final group = _filteredGroups[index];
                return SwipeableExpenseGroupCard(
                  trip: group,
                  onArchiveToggle: _onArchiveToggle,
                  onDelete: _loadGroups,
                  onPin: _loadGroups,
                  searchQuery: _searchQuery,
                );
              },
            ),
    );
  }
}
