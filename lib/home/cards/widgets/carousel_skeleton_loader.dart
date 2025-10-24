import 'package:flutter/material.dart';

/// A skeleton loader widget that displays animated placeholder cards
/// while the carousel data is being loaded. Provides smooth UX during cold start.
class CarouselSkeletonLoader extends StatefulWidget {
  final ThemeData theme;

  const CarouselSkeletonLoader({
    super.key,
    required this.theme,
  });

  @override
  State<CarouselSkeletonLoader> createState() => _CarouselSkeletonLoaderState();
}

class _CarouselSkeletonLoaderState extends State<CarouselSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.theme.colorScheme;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Column(
          children: [
            // Main skeleton cards area
            Expanded(
              child: PageView.builder(
                itemCount: 3, // Show 3 skeleton cards
                controller: PageController(viewportFraction: 0.85),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // Add slight delay to each card animation for wave effect
                  final shimmerValue = (_shimmerController.value +
                          (index * 0.1)) %
                      1.0;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 16, bottom: 16),
                    child: _SkeletonCard(
                      shimmerValue: shimmerValue,
                      colorScheme: colorScheme,
                    ),
                  );
                },
              ),
            ),
            // Skeleton page indicators
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Individual skeleton card with shimmer effect
class _SkeletonCard extends StatelessWidget {
  final double shimmerValue;
  final ColorScheme colorScheme;

  const _SkeletonCard({
    required this.shimmerValue,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Create shimmer gradient
    final shimmerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ],
      stops: [
        (shimmerValue - 0.3).clamp(0.0, 1.0),
        shimmerValue,
        (shimmerValue + 0.3).clamp(0.0, 1.0),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Shimmer effect overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: shimmerGradient,
            ),
          ),
          // Card content skeleton
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                _SkeletonBox(
                  width: 160,
                  height: 24,
                  borderRadius: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
                // Subtitle skeleton
                _SkeletonBox(
                  width: 120,
                  height: 16,
                  borderRadius: 8,
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
                        _SkeletonBox(
                          width: 80,
                          height: 14,
                          borderRadius: 7,
                          color: colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                        const SizedBox(height: 8),
                        _SkeletonBox(
                          width: 100,
                          height: 20,
                          borderRadius: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    _SkeletonBox(
                      width: 56,
                      height: 56,
                      borderRadius: 28,
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
  }
}

/// Simple skeleton box widget
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const _SkeletonBox({
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
