import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'dart:math' as math;

import 'carousel_group_card.dart';
import '../../navigation_helpers.dart';

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

/// Widget helper that draws a rounded dashed border around [child].
class _DashedBorder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final Widget? child;

  const _DashedBorder({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 6,
    this.gapLength = 4,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        foregroundPainter: _DashPainter(
          color: color,
          strokeWidth: strokeWidth,
          dashLength: dashLength,
          gapLength: gapLength,
          radius: radius,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  _DashPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = math.min(dashLength, metric.length - distance);
        final extracted = metric.extractPath(distance, distance + next);
        canvas.drawPath(extracted, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.radius != radius;
  }
}

class _HorizontalGroupsListState extends State<HorizontalGroupsList>
    with SingleTickerProviderStateMixin {
  late List<ExpenseGroup> _localGroups;
  bool _isLoadingNewGroup = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _localGroups = List.from(widget.groups);

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
  }

  @override
  void didUpdateWidget(HorizontalGroupsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna solo se i gruppi sono effettivamente cambiati
    if (oldWidget.groups != widget.groups) {
      // Check if a new group was added
      if (widget.groups.length > _localGroups.length) {
        if (_isLoadingNewGroup) {
          setState(() {
            _isLoadingNewGroup = false;
            _localGroups = List.from(widget.groups);
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
      // Specific group ID provided - update locally
      setState(() {
        _isLoadingNewGroup = true;
      });

      await _updateGroupLocally(groupId);

      if (mounted) {
        setState(() {
          _isLoadingNewGroup = false;
        });
      }
    } else {
      // No group ID provided - call parent's onGroupAdded
      setState(() {
        _isLoadingNewGroup = true;
      });

      // Call parent callback which will refresh the list
      widget.onGroupAdded();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total items: groups + 1 for "add new" card
    final totalItems = _localGroups.length + 1;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: CarouselGroupCard.totalHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 0),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // Last item is the "add new group" card
            if (index == _localGroups.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _AddNewGroupTile(
                  localizations: widget.localizations,
                  theme: widget.theme,
                  onGroupAdded: _handleGroupUpdated,
                ),
              );
            }

            final group = _localGroups[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CarouselGroupCard(
                group: group,
                localizations: widget.localizations,
                theme: widget.theme,
                onGroupUpdated: () => _handleGroupUpdated(group.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Compact "Add New Group" tile for the carousel
class _AddNewGroupTile extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final void Function([String? groupId]) onGroupAdded;

  const _AddNewGroupTile({
    required this.localizations,
    required this.theme,
    required this.onGroupAdded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CarouselGroupCard.tileSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Square tile with + icon (dashed border) - wrapped with inkwell
          ClipOval(
            child: Stack(
              children: [
                // Background con dashed border
                _DashedBorder(
                  width: CarouselGroupCard.tileSize,
                  height: CarouselGroupCard.tileSize,
                  radius: CarouselGroupCard.tileBorderRadius,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 2,
                  dashLength: 6,
                  gapLength: 10,
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
                // InkWell sopra tutto
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await NavigationHelpers.openGroupCreationWithCallback(
                        context,
                        onGroupAdded: onGroupAdded,
                      );
                    },
                    splashColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    highlightColor: theme.colorScheme.primary.withValues(
                      alpha: 0.05,
                    ),
                    child: SizedBox(
                      width: CarouselGroupCard.tileSize,
                      height: CarouselGroupCard.tileSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Title (non cliccabile)
          Text(
            localizations.new_expense_group,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
