import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import 'group_card.dart';
import 'group_card_skeleton.dart';
import 'new_group_card.dart';

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
  bool _isLoadingNewGroup = false;
  String? _pendingGroupId;

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
      // Check if a new group was added
      if (widget.groups.length > _localGroups.length) {
        // If we were showing a skeleton and now have more groups, animate to first
        if (_isLoadingNewGroup) {
          setState(() {
            _isLoadingNewGroup = false;
            _localGroups = List.from(widget.groups);
          });
          // Smooth animation to the new group
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _pageController.hasClients) {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            }
          });
        } else {
          _localGroups = List.from(widget.groups);
        }
      } else {
        _localGroups = List.from(widget.groups);
      }
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
            // Update existing group
            _localGroups[index] = updatedGroup;
          } else {
            // New group - add it at the beginning
            _localGroups.insert(0, updatedGroup);
          }
        });
      }
    } else {
      // Fallback al callback originale se non trovato
      widget.onGroupUpdated();
    }
  }

  void _handleGroupUpdated([String? groupId]) async {
    if (groupId != null) {
      // Specific group ID provided - update it locally
      // Show skeleton while loading
      setState(() {
        _isLoadingNewGroup = true;
      });
      
      // Small delay to show the skeleton animation
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _updateGroupLocally(groupId);
      
      if (mounted) {
        setState(() {
          _isLoadingNewGroup = false;
        });
        
        // Animate to the new group (first position) if it was newly added
        final groupIndex = _localGroups.indexWhere((g) => g.id == groupId);
        if (groupIndex == 0) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        }
      }
    } else {
      // No group ID provided - this means a new group was added
      // Show skeleton and let the parent refresh
      setState(() {
        _isLoadingNewGroup = true;
      });
      
      // Call parent callback which will refresh the list
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
    // Add 1 extra for skeleton if loading
    final totalItems = _localGroups.length + 1 + (_isLoadingNewGroup ? 1 : 0);

    return PageView.builder(
      itemCount: totalItems,
      padEnds: false,
      controller: _pageController,
      itemBuilder: (context, index) {
        // Calcola quanto questa card è vicina al centro
        final double distanceFromCenter = (index - _currentPage).abs();
        final bool isSelected = distanceFromCenter < 0.5;

        // Show skeleton at first position if loading
        if (_isLoadingNewGroup && index == 0) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              right: 16,
              top: isSelected ? 0 : 8,
              bottom: isSelected ? 0 : 8,
            ),
            child: GroupCardSkeleton(
              isSelected: isSelected,
              selectionProgress: 1.0 - distanceFromCenter.clamp(0.0, 1.0),
            ),
          );
        }

        // Adjust index if skeleton is shown
        final adjustedIndex = _isLoadingNewGroup ? index - 1 : index;

        // If this is the last index, show the new group card
        if (adjustedIndex == _localGroups.length) {
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
        final group = _localGroups[adjustedIndex];
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
    );
  }
}
