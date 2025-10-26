import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import 'carousel_skeleton_loader.dart';
import 'group_card.dart';
import 'new_group_card.dart';
import 'page_indicator.dart';

class HorizontalGroupsList extends StatefulWidget {
  final List<ExpenseGroup> groups;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback onGroupAdded;
  final VoidCallback? onCategoryAdded;

  const HorizontalGroupsList({
    super.key,
    required this.groups,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    required this.onGroupAdded,
    this.onCategoryAdded,
  });

  @override
  State<HorizontalGroupsList> createState() => _HorizontalGroupsListState();
}

class _HorizontalGroupsListState extends State<HorizontalGroupsList>
    with TickerProviderStateMixin {
  late PageController _pageController;
  double _currentPage = 0.0;
  late List<ExpenseGroup> _localGroups;
  bool _isLoadingNewGroup = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _shimmerController;

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

    // Setup fade-in animation for smooth loading
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Setup shimmer animation for skeleton cards
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
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
      // Specific group ID provided - show skeleton immediately for smooth UX
      setState(() {
        _isLoadingNewGroup = true;
      });

      // Update the group locally
      await _updateGroupLocally(groupId);

      if (mounted) {
        setState(() {
          _isLoadingNewGroup = false;
        });

        // Animate to the new group (first position) with smooth transition
        final groupIndex = _localGroups.indexWhere((g) => g.id == groupId);
        if (groupIndex == 0 && _pageController.hasClients) {
          // New group added at top - animate smoothly
          await Future.delayed(const Duration(milliseconds: 150));
          if (mounted && _pageController.hasClients) {
            await _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }
        } else if (groupIndex > 0 && _pageController.hasClients) {
          // Updated existing group - animate to its position
          await Future.delayed(const Duration(milliseconds: 150));
          if (mounted && _pageController.hasClients) {
            await _pageController.animateToPage(
              groupIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }
        }
      }
    } else {
      // No group ID provided - show skeleton and call parent's onGroupAdded
      setState(() {
        _isLoadingNewGroup = true;
      });

      // Call parent callback which will refresh the list
      widget.onGroupAdded();
    }
  }

  void _handleCategoryAdded() {
    widget.onCategoryAdded?.call();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total items include all groups plus the new group card
    // Add 1 extra for skeleton if loading
    final totalItems = _localGroups.length + 1 + (_isLoadingNewGroup ? 1 : 0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
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
                    child: SkeletonCard(
                      shimmerValue: _shimmerController.value,
                      colorScheme: widget.theme.colorScheme,
                      isSelected: isSelected,
                      selectionProgress: 1.0 - distanceFromCenter.clamp(0.0, 1.0),
                      enableEntranceAnimation: true,
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
                      selectionProgress:
                          1.0 - distanceFromCenter.clamp(0.0, 1.0),
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
      ),
    );
  }
}
