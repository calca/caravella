import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../../../home/home_constants.dart';

/// Shared constants for skeleton loaders
class SkeletonConstants {
  /// Default border radius for card skeletons
  static const double cardBorderRadius = HomeLayoutConstants.cardBorderRadius;

  /// Default shimmer animation duration
  static const Duration shimmerDuration =
      HomeLayoutConstants.shimmerAnimationDuration;

  /// Default padding for card content
  static const EdgeInsets cardPadding = HomeLayoutConstants.cardPadding;
}

/// Creates a shimmer gradient based on the animation value and color scheme.
///
/// The gradient animates from left to right creating a loading effect.
LinearGradient createShimmerGradient(
  double animationValue,
  ColorScheme colorScheme,
) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    ],
    stops: [
      (animationValue - 0.3).clamp(0.0, 1.0),
      animationValue,
      (animationValue + 0.3).clamp(0.0, 1.0),
    ],
  );
}

/// A simple skeleton box widget used for placeholder content.
///
/// Displays a rounded rectangle with a solid color to represent
/// loading content like text lines, avatars, or buttons.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton widget for the featured card shown during loading.
///
/// Displays an animated placeholder with shimmer effect that mimics
/// the structure of a [GroupCard] widget.
class FeaturedCardSkeleton extends StatefulWidget {
  final ThemeData theme;

  const FeaturedCardSkeleton({super.key, required this.theme});

  @override
  State<FeaturedCardSkeleton> createState() => _FeaturedCardSkeletonState();
}

class _FeaturedCardSkeletonState extends State<FeaturedCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: SkeletonConstants.shimmerDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final colorScheme = widget.theme.colorScheme;
        final skeletonColor = colorScheme.onSurface.withValues(alpha: 0.1);
        final skeletonColorLight = colorScheme.onSurface.withValues(
          alpha: 0.08,
        );

        // Use BaseCard as container - same as real GroupCard
        return BaseCard(
          margin: const EdgeInsets.only(bottom: 16),
          backgroundColor: colorScheme.surfaceContainer,
          child: Stack(
            children: [
              // Shimmer effect overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: createShimmerGradient(
                      _shimmerController.value,
                      colorScheme,
                    ),
                  ),
                ),
              ),
              // Card content skeleton - matches GroupCardContent structure
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header skeleton (title)
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonBox(
                          width: 180,
                          height: 24,
                          borderRadius: 12,
                          color: skeletonColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date range skeleton with icon
                  Row(
                    children: [
                      SkeletonBox(
                        width: 14,
                        height: 14,
                        borderRadius: 7,
                        color: skeletonColorLight,
                      ),
                      const SizedBox(width: 4),
                      SkeletonBox(
                        width: 100,
                        height: 14,
                        borderRadius: 7,
                        color: skeletonColorLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Centered total amount skeleton
                  Center(
                    child: SkeletonBox(
                      width: 160,
                      height: 48,
                      borderRadius: 24,
                      color: skeletonColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Today's spending badge skeleton (colored pill)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SkeletonBox(
                            width: 50,
                            height: 16,
                            borderRadius: 8,
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 8),
                          SkeletonBox(
                            width: 70,
                            height: 14,
                            borderRadius: 7,
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // "RECENT EXPENSES" label skeleton
                  SkeletonBox(
                    width: 120,
                    height: 10,
                    borderRadius: 5,
                    color: skeletonColorLight,
                  ),
                  const SizedBox(height: 8),
                  // Recent expense cards skeleton (2 compact cards)
                  _buildRecentExpenseSkeleton(
                    colorScheme,
                    skeletonColor,
                    skeletonColorLight,
                  ),
                  const SizedBox(height: 6),
                  _buildRecentExpenseSkeleton(
                    colorScheme,
                    skeletonColor,
                    skeletonColorLight,
                  ),
                  const SizedBox(height: 8),
                  // Add button skeleton
                  SkeletonBox(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 20,
                    color: skeletonColorLight,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a skeleton for a single recent expense card
  Widget _buildRecentExpenseSkeleton(
    ColorScheme colorScheme,
    Color skeletonColor,
    Color skeletonColorLight,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Category icon skeleton
          SkeletonBox(
            width: 32,
            height: 32,
            borderRadius: 16,
            color: skeletonColorLight,
          ),
          const SizedBox(width: 12),
          // Expense name and category skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 100,
                  height: 14,
                  borderRadius: 7,
                  color: skeletonColor,
                ),
                const SizedBox(height: 4),
                SkeletonBox(
                  width: 60,
                  height: 10,
                  borderRadius: 5,
                  color: skeletonColorLight,
                ),
              ],
            ),
          ),
          // Amount skeleton
          SkeletonBox(
            width: 60,
            height: 16,
            borderRadius: 8,
            color: skeletonColor,
          ),
        ],
      ),
    );
  }
}
