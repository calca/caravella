/// Shared spacing tokens for the design system, derived from the padding
/// values already in common use across the app (grep histogram over
/// `EdgeInsets.*` in `lib/`, see `plan.todo.ds.md` Fase 2). Values follow
/// the 4dp grid the app already uses in practice, including the 20.0 step
/// used by [BaseCard]'s default padding.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}
