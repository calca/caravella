import 'package:flutter/material.dart';
import 'home_skeleton_widgets.dart';

/// A skeleton loader widget that displays animated placeholder cards
/// while the carousel data is being loaded. Provides smooth UX during cold start.
class CarouselSkeletonLoader extends StatefulWidget {
  final ThemeData theme;

  const CarouselSkeletonLoader({super.key, required this.theme});

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
                  final shimmerValue =
                      (_shimmerController.value + (index * 0.1)) % 1.0;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 16, bottom: 16),
                    child: SkeletonCard(
                      shimmerValue: shimmerValue,
                      colorScheme: colorScheme,
                      enableEntranceAnimation: false,
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

/// Unified skeleton card with optional entrance animations.
/// Can be used for both initial loading (multiple static cards)
/// and dynamic insertion (single animated card).
class SkeletonCard extends StatefulWidget {
  final double shimmerValue;
  final ColorScheme colorScheme;
  final bool isSelected;
  final double selectionProgress;
  final bool enableEntranceAnimation;

  const SkeletonCard({
    super.key,
    required this.shimmerValue,
    required this.colorScheme,
    this.isSelected = false,
    this.selectionProgress = 0.0,
    this.enableEntranceAnimation = false,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _entranceController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Only create entrance animations if enabled
    if (widget.enableEntranceAnimation) {
      _entranceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );

      _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController!,
          curve: Curves.easeOutCubic,
        ),
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entranceController!, curve: Curves.easeIn),
      );

      _entranceController!.forward();
    }
  }

  @override
  void dispose() {
    _entranceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create shimmer gradient using shared helper
    final shimmerGradient = createShimmerGradient(
      widget.shimmerValue,
      widget.colorScheme,
    );

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(SkeletonConstants.cardBorderRadius),
        border: Border.all(
          color: widget.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: widget.colorScheme.shadow.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
                  width: 160,
                  height: 24,
                  borderRadius: 12,
                  color: widget.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
                // Subtitle skeleton
                SkeletonBox(
                  width: 120,
                  height: 16,
                  borderRadius: 8,
                  color: widget.colorScheme.onSurface.withValues(alpha: 0.08),
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
                          width: 80,
                          height: 14,
                          borderRadius: 7,
                          color: widget.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SkeletonBox(
                          width: 100,
                          height: 20,
                          borderRadius: 10,
                          color: widget.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ],
                    ),
                    SkeletonBox(
                      width: 56,
                      height: 56,
                      borderRadius: 28,
                      color: widget.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap with entrance animations if enabled
    if (widget.enableEntranceAnimation &&
        _scaleAnimation != null &&
        _fadeAnimation != null) {
      return ScaleTransition(
        scale: _scaleAnimation!,
        child: FadeTransition(opacity: _fadeAnimation!, child: cardContent),
      );
    }

    return cardContent;
  }
}
