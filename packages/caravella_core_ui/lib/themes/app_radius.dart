/// Shared corner-radius tokens for the design system, derived from the
/// values already dominant across the app (grep histogram over
/// `BorderRadius.circular(...)` in `lib/`, see `plan.todo.ds.md` Fase 3).
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;

  /// Material 3 large-shape corner radius used for dialogs.
  static const double dialog = 28.0;
}
