import 'package:flutter/material.dart';

/// A skeleton placeholder widget that displays while group cards are loading.
/// Uses a shimmer-like animation to indicate loading state.
class GroupCardSkeleton extends StatefulWidget {
  final bool isSelected;
  final double selectionProgress;

  const GroupCardSkeleton({
    super.key,
    this.isSelected = false,
    this.selectionProgress = 0.0,
  });

  @override
  State<GroupCardSkeleton> createState() => _GroupCardSkeletonState();
}

class _GroupCardSkeletonState extends State<GroupCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Base colors for skeleton
    final baseColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHigh;
    final highlightColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: widget.isSelected ? 8 : 2,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    _shimmerAnimation.value - 0.3,
                    _shimmerAnimation.value,
                    _shimmerAnimation.value + 0.3,
                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
                  colors: [
                    baseColor,
                    highlightColor,
                    baseColor,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skeleton for group name
                    Container(
                      width: 180,
                      height: 28,
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Skeleton for subtitle/description
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    // Skeleton for stats/info at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
