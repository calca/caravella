import 'package:material_ui/material_ui.dart';

/// Hairline drawn over a card's edge so it stands out from the page
/// background, also over photos and palette colors (black 8% in light theme,
/// white 10% in dark theme).
class CardOutline extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;

  const CardOutline({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  /// The outline color for [brightness].
  static Color colorFor(Brightness brightness) => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.black.withValues(alpha: 0.08);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      border: Border.all(color: colorFor(Theme.of(context).brightness)),
    ),
    child: child,
  );
}
