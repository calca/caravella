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
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Add scale-in animation for smooth appearance
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeIn));

    _scaleController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Create shimmer gradient matching CarouselSkeletonLoader style
    final shimmerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ],
      stops: [
        (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
        _shimmerAnimation.value,
        (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
      ],
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: double.infinity,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Shimmer effect overlay
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: shimmerGradient,
                      ),
                    );
                  },
                ),
                // Card content skeleton
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        width: 160,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle skeleton
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Spacer(),
                      // Stats skeleton at bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
