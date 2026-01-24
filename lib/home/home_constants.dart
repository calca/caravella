import 'package:flutter/material.dart';

/// Centralized layout constants for the home module.
///
/// This class contains all hardcoded values related to layout,
/// spacing, and visual properties used across home widgets.
class HomeLayoutConstants {
  HomeLayoutConstants._();

  // ==================== Border Radius ====================

  /// Standard border radius for cards and containers
  static const double cardBorderRadius = 24.0;

  /// Border radius for buttons and small elements
  static const double buttonBorderRadius = 12.0;

  /// Border radius for carousel tiles
  static const double tileBorderRadius = 12.0;

  // ==================== Spacing ====================

  /// Standard horizontal padding for content
  static const double horizontalPadding = 20.0;

  /// Standard vertical spacing between sections
  static const double sectionSpacing = 16.0;

  /// Small spacing between elements
  static const double smallSpacing = 8.0;

  /// Large spacing between major sections
  static const double largeSpacing = 24.0;

  /// Card content padding
  static const EdgeInsets cardPadding = EdgeInsets.all(24.0);

  /// Standard card margin
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 16.0);

  // ==================== Heights ====================

  /// Height of carousel group card tiles
  static const double carouselTileSize = 90.0;

  /// Total height of carousel card including text
  /// (tile + spacing + title + spacing + balance)
  static const double carouselCardTotalHeight = carouselTileSize + 38;

  // ==================== Animation Durations ====================

  /// Duration for container animations (e.g., selection state)
  static const Duration containerAnimationDuration = Duration(
    milliseconds: 300,
  );

  /// Duration for shimmer/skeleton animations
  static const Duration shimmerAnimationDuration = Duration(milliseconds: 1500);

  /// Duration for fade-in animations
  static const Duration fadeAnimationDuration = Duration(milliseconds: 400);

  /// Duration for page transitions
  static const Duration pageTransitionDuration = Duration(milliseconds: 350);

  // ==================== Animation Curves ====================

  /// Standard easing curve for UI animations
  static const Curve standardCurve = Curves.easeInOut;

  /// Curve for entrance animations
  static const Curve entranceCurve = Curves.easeOutCubic;

  /// Curve for exit animations
  static const Curve exitCurve = Curves.easeInCubic;

  // ==================== Opacity/Alpha Values ====================

  /// Border outline alpha
  static const double borderAlpha = 0.2;

  /// Shadow alpha for elevated cards
  static const double shadowAlpha = 0.15;

  /// Selection highlight intensity (30%)
  static const double selectionIntensity = 0.3;

  /// Muted text alpha
  static const double mutedTextAlpha = 0.7;

  /// Very muted text/element alpha
  static const double veryMutedAlpha = 0.65;

  // ==================== Font Sizes (Group Card Content) ====================

  /// Title font size in group cards
  static const double cardTitleFontSize = 28.0;

  /// Total amount font size
  static const double cardTotalFontSize = 52.0;

  /// Currency symbol font size
  static const double cardCurrencyFontSize = 32.0;

  // ==================== Icon Sizes ====================

  /// Standard icon size
  static const double standardIconSize = 20.0;

  /// Large icon size (for add button, etc.)
  static const double largeIconSize = 28.0;

  // ==================== Header ====================

  /// Fixed height of compact header (avatar + text + padding)
  static const double headerHeight =
      56.0 + 32.0; // 56 avatar + 32 padding (16 top + 16 bottom)

  // ==================== Layout Proportions ====================

  /// Featured card height as proportion of content area
  static const double featuredCardHeightRatio = 0.66;

  /// Carousel height as proportion of content area
  static const double carouselHeightRatio = 0.34;

  /// Bottom bar height as proportion of screen height
  static const double bottomBarHeightRatio = 1 / 6;

  /// Bottom bar additional padding (added to safe area)
  static const double bottomBarExtraPadding = 16.0;
}
