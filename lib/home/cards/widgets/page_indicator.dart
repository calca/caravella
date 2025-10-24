import 'package:flutter/material.dart';

/// A custom page indicator widget that displays dots representing pages in a slider.
/// Follows Material 3 design principles and includes proper accessibility support.
class PageIndicator extends StatelessWidget {
  final int itemCount;
  final double currentPage;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;
  final String? semanticLabel;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use theme colors if not specified
    final activeIndicatorColor = activeColor ?? colorScheme.onSurface;
    final inactiveIndicatorColor = inactiveColor ?? colorScheme.onSurface;

    // Calculate which page is currently active (rounded to nearest integer)
    final activePage = currentPage.round();

    // Build semantic label for accessibility
    final String accessibilityLabel =
        semanticLabel ?? 'Page ${activePage + 1} of $itemCount';

    return Semantics(
      label: accessibilityLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: dotSize * 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(itemCount, (index) {
              // Calculate distance from current page for smooth animation
              final distance = (index - currentPage).abs();
              final isActive = distance < 0.5;

              // Animate size and opacity based on distance
              final scale = isActive ? 1.0 : 0.7;
              final opacity = isActive
                  ? 0.4
                  : (0.4 - (distance * 0.4)).clamp(0.1, 0.4).toDouble();

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: dotSize * scale,
                height: dotSize * scale,
                margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? activeIndicatorColor.withValues(alpha: opacity)
                      : inactiveIndicatorColor.withValues(alpha: opacity),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
