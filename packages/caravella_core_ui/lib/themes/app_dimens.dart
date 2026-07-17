/// Shared sizing tokens for the design system.
class AppDimens {
  AppDimens._();

  /// Material 3 / WCAG 2.2 (SC 2.5.8) recommended minimum touch target.
  static const double minTouchTarget = 48.0;

  /// Reduced touch target for dense UI where [minTouchTarget] doesn't fit
  /// (e.g. inline icon buttons next to text). Still above the WCAG 2.5.8
  /// minimum of 24x24.
  static const double minTouchTargetCompact = 44.0;

  /// The WCAG 2.5.8 (SC 2.5.8 Target Size, AA) absolute floor. Only use this
  /// for targets embedded inline in a text flow (e.g. a `WidgetSpan` button)
  /// where [minTouchTargetCompact] would break the surrounding layout —
  /// everywhere else, prefer [minTouchTargetCompact] or [minTouchTarget].
  static const double minTouchTargetInline = 24.0;
}
