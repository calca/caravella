import 'package:flutter/material.dart';
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
        final shimmerGradient = createShimmerGradient(
          _shimmerController.value,
          colorScheme,
        );

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(
              SkeletonConstants.cardBorderRadius,
            ),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    SkeletonConstants.cardBorderRadius,
                  ),
                  gradient: shimmerGradient,
                ),
              ),
              // Card content skeleton
              Padding(
                padding: SkeletonConstants.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    SkeletonBox(
                      width: 200,
                      height: 28,
                      borderRadius: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle skeleton
                    SkeletonBox(
                      width: 160,
                      height: 20,
                      borderRadius: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                    const Spacer(),
                    // Stats skeleton at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(
                              width: 100,
                              height: 16,
                              borderRadius: 8,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SkeletonBox(
                              width: 120,
                              height: 24,
                              borderRadius: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ],
                        ),
                        SkeletonBox(
                          width: 64,
                          height: 64,
                          borderRadius: 32,
                          color: colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
