import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import 'group_card.dart';
import 'new_group_card.dart';
import 'page_indicator.dart';

class HorizontalGroupsList extends StatefulWidget {
  final List<ExpenseGroup> groups;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback? onCategoryAdded;

  const HorizontalGroupsList({
    super.key,
    required this.groups,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    this.onCategoryAdded,
  });

  @override
  State<HorizontalGroupsList> createState() => _HorizontalGroupsListState();
}

class _HorizontalGroupsListState extends State<HorizontalGroupsList> {
  late PageController _pageController;
  double _currentPage = 0.0;
  late List<ExpenseGroup> _localGroups;

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _localGroups = List.from(widget.groups);
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(_onPageChanged);
  }

  @override
  void didUpdateWidget(HorizontalGroupsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna solo se i gruppi sono effettivamente cambiati
    if (oldWidget.groups != widget.groups) {
      _localGroups = List.from(widget.groups);
    }
  }

  Future<void> _updateGroupLocally(String groupId) async {
    final groups = await ExpenseGroupStorageV2.getAllGroups();
    final found = groups.where((g) => g.id == groupId);
    if (found.isNotEmpty) {
      final updatedGroup = found.first;
      if (mounted) {
        setState(() {
          final index = _localGroups.indexWhere((g) => g.id == groupId);
          if (index != -1) {
            _localGroups[index] = updatedGroup;
          }
        });
      }
    } else {
      // Fallback al callback originale se non trovato
      widget.onGroupUpdated();
    }
  }

  void _handleGroupUpdated([String? groupId]) {
    if (groupId != null) {
      _updateGroupLocally(groupId);
    } else {
      widget.onGroupUpdated();
    }
  }

  void _handleCategoryAdded() {
    widget.onCategoryAdded?.call();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total items include all groups plus the new group card
    final totalItems = _localGroups.length + 1;

    return Column(
      children: [
        // Main PageView slider
        Expanded(
          child: PageView.builder(
            itemCount: totalItems,
            padEnds: false,
            controller: _pageController,
            itemBuilder: (context, index) {
              // Calcola quanto questa card è vicina al centro
              final double distanceFromCenter = (index - _currentPage).abs();
              final bool isSelected = distanceFromCenter < 0.5;

              // If this is the last index, show the new group card
              if (index == _localGroups.length) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(
                    right: 16,
                    top: isSelected ? 0 : 8,
                    bottom: isSelected ? 0 : 8,
                  ),
                  child: NewGroupCard(
                    localizations: widget.localizations,
                    theme: widget.theme,
                    onGroupAdded: _handleGroupUpdated,
                    isSelected: isSelected,
                    selectionProgress: 1.0 - distanceFromCenter.clamp(0.0, 1.0),
                  ),
                );
              }

              // Otherwise show a regular group card
              final group = _localGroups[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  right: 16,
                  top: isSelected ? 0 : 8,
                  bottom: isSelected ? 0 : 8,
                ),
                child: GroupCard(
                  group: group,
                  localizations: widget.localizations,
                  theme: widget.theme,
                  onGroupUpdated: () => _handleGroupUpdated(group.id),
                  onCategoryAdded: _handleCategoryAdded,
                  isSelected: isSelected,
                  selectionProgress: 1.0 - distanceFromCenter.clamp(0.0, 1.0),
                ),
              );
            },
          ),
        ),
        // Page indicator
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: PageIndicator(
            itemCount: totalItems,
            currentPage: _currentPage,
          ),
        ),
      ],
    );
  }
}
