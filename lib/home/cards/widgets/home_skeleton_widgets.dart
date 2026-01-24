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
                  // Header skeleton (title + pin badge area)
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonBox(
                          width: 180,
                          height: 28,
                          borderRadius: 14,
                          color: skeletonColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date range skeleton
                  SkeletonBox(
                    width: 140,
                    height: 16,
                    borderRadius: 8,
                    color: skeletonColorLight,
                  ),
                  const SizedBox(height: HomeLayoutConstants.largeSpacing),
                  // Total amount skeleton
                  SkeletonBox(
                    width: 160,
                    height: 32,
                    borderRadius: 16,
                    color: skeletonColor,
                  ),
                  const Spacer(),
                  // Stats skeleton (chart + extra info)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Chart skeleton
                      Expanded(
                        child: SkeletonBox(
                          width: double.infinity,
                          height: 60,
                          borderRadius: 8,
                          color: skeletonColorLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Extra info skeleton (today's spending)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SkeletonBox(
                            width: 60,
                            height: 14,
                            borderRadius: 7,
                            color: skeletonColorLight,
                          ),
                          const SizedBox(height: 4),
                          SkeletonBox(
                            width: 80,
                            height: 20,
                            borderRadius: 10,
                            color: skeletonColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: HomeLayoutConstants.largeSpacing),
                  // Add button skeleton
                  SkeletonBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 24,
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
}
