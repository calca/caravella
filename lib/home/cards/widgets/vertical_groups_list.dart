import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import 'group_card.dart';
import 'new_group_card.dart';

class VerticalGroupsList extends StatefulWidget {
  final List<ExpenseGroup> groups;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback? onCategoryAdded;

  const VerticalGroupsList({
    super.key,
    required this.groups,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    this.onCategoryAdded,
  });

  @override
  State<VerticalGroupsList> createState() => _VerticalGroupsListState();
}

class _VerticalGroupsListState extends State<VerticalGroupsList>
    with TickerProviderStateMixin {
  late List<ExpenseGroup> _localGroups;
  late AnimationController _animationController;
  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardAnimations = [];

  @override
  void initState() {
    super.initState();
    _localGroups = List.from(widget.groups);
    
    // Main animation controller for the list entrance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _setupCardAnimations();
    _animationController.forward();
  }

  void _setupCardAnimations() {
    // Clear existing controllers
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    _cardControllers.clear();
    _cardAnimations.clear();

    // Create staggered animations for each card
    final totalCards = _localGroups.length + 1; // +1 for new group card
    for (int i = 0; i < totalCards; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _cardControllers.add(controller);

      // Staggered delay based on position
      final delay = i * 80; // 80ms delay between cards
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          controller.forward();
        }
      });

      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
      _cardAnimations.add(animation);
    }
  }

  @override
  void didUpdateWidget(VerticalGroupsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groups != widget.groups) {
      setState(() {
        _localGroups = List.from(widget.groups);
      });
      _setupCardAnimations();
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
    _animationController.dispose();
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Build pinned card first if it exists
                ExpenseGroup? pinnedGroup;
                try {
                  pinnedGroup = _localGroups.firstWhere((g) => g.pinned);
                } catch (_) {
                  pinnedGroup = null;
                }
                final regularGroups = _localGroups.where((g) => !g.pinned).toList();
                final totalItems = (pinnedGroup != null ? 1 : 0) + regularGroups.length + 1;

                if (index >= totalItems) return null;

                // Get animation for this card
                final animation = index < _cardAnimations.length
                    ? _cardAnimations[index]
                    : _cardAnimations.last;

                // First show pinned card if exists
                if (pinnedGroup != null && index == 0) {
                  return _buildAnimatedCard(
                    animation: animation,
                    child: _PinnedGroupCard(
                      group: pinnedGroup,
                      localizations: widget.localizations,
                      theme: widget.theme,
                      onGroupUpdated: () => _handleGroupUpdated(pinnedGroup!.id),
                      onCategoryAdded: _handleCategoryAdded,
                    ),
                  );
                }

                // Calculate actual index in regular groups
                final regularIndex = pinnedGroup != null ? index - 1 : index;

                // Show new group card as last item
                if (regularIndex == regularGroups.length) {
                  return _buildAnimatedCard(
                    animation: animation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: NewGroupCard(
                        localizations: widget.localizations,
                        theme: widget.theme,
                        onGroupAdded: _handleGroupUpdated,
                        isSelected: true,
                        selectionProgress: 1.0,
                      ),
                    ),
                  );
                }

                // Show regular group cards
                final group = regularGroups[regularIndex];
                return _buildAnimatedCard(
                  animation: animation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildGroupCard(group),
                  ),
                );
              },
              childCount: (_localGroups.where((g) => g.pinned).isNotEmpty ? 1 : 0) +
                  _localGroups.where((g) => !g.pinned).length +
                  1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildGroupCard(ExpenseGroup group) {
    return Hero(
      tag: 'group_${group.id}',
      child: Material(
        type: MaterialType.transparency,
        child: GroupCard(
          group: group,
          localizations: widget.localizations,
          theme: widget.theme,
          onGroupUpdated: () => _handleGroupUpdated(group.id),
          onCategoryAdded: _handleCategoryAdded,
          isSelected: true,
          selectionProgress: 1.0,
        ),
      ),
    );
  }
}

/// Special widget for pinned card with enhanced visual prominence
class _PinnedGroupCard extends StatefulWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback? onCategoryAdded;

  const _PinnedGroupCard({
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    this.onCategoryAdded,
  });

  @override
  State<_PinnedGroupCard> createState() => _PinnedGroupCardState();
}

class _PinnedGroupCardState extends State<_PinnedGroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.02),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Hero(
                tag: 'group_${widget.group.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: GroupCard(
                    group: widget.group,
                    localizations: widget.localizations,
                    theme: widget.theme,
                    onGroupUpdated: widget.onGroupUpdated,
                    onCategoryAdded: widget.onCategoryAdded,
                    isSelected: true,
                    selectionProgress: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
