/// Shared sizing tokens for the design system.
class AppDimens {
  AppDimens._();

  /// Material 3 / WCAG 2.2 (SC 2.5.8) recommended minimum touch target.
  static const double minTouchTarget = 48.0;

  /// Reduced touch target for dense UI where [minTouchTarget] doesn't fit
  /// (e.g. inline icon buttons next to text). Still above the WCAG 2.5.8
  /// minimum of 24x24.
  static const double minTouchTargetCompact = 44.0;
}
