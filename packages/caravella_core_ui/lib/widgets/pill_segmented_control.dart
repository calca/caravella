import 'package:material_ui/material_ui.dart';

import 'floating_nav_bar.dart';

/// Pill-shaped segmented control in the floating navigation's style: a
/// neutral pill with the selected segment on a tonal fill (e.g. Active /
/// Archived on Groups, Expenses / Balances / Statistics on a group).
///
/// With [expand] the segments share the available width equally; otherwise
/// the control sizes to its labels. Changing [selectedIndex] slides the
/// selected fill over to the new segment (instant when the system disables
/// animations).
class PillSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool expand;

  const PillSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.expand = false,
  });

  // 48 dp: Material's minimum touch target.
  static const double _height = 48;
  static const double _padding = 4;
  static const Duration _duration = Duration(milliseconds: 320);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final style = theme.textTheme.labelLarge;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _duration;

    // Natural segment widths: the label (measured bold, so selecting doesn't
    // shift anything) plus 18 dp on each side.
    final textScaler = MediaQuery.textScalerOf(context);
    final natural = [
      for (final label in labels)
        (TextPainter(
              text: TextSpan(
                text: label,
                style: style?.copyWith(fontWeight: FontWeight.w700),
              ),
              maxLines: 1,
              textDirection: Directionality.of(context),
              textScaler: textScaler,
            )..layout()).width.ceilToDouble() +
            36,
    ];

    Widget pill(List<double> widths) {
      final lefts = <double>[];
      var x = 0.0;
      for (final w in widths) {
        lefts.add(x);
        x += w;
      }
      return DecoratedBox(
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: FloatingNavBar.pillColor(s),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: SizedBox(
            width: x,
            height: _height,
            child: Stack(
              children: [
                // The selected fill slides to the new segment, like the
                // floating navigation's.
                AnimatedPositioned(
                  duration: duration,
                  curve: _curve,
                  left: lefts[selectedIndex],
                  width: widths[selectedIndex],
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: FloatingNavBar.selectedColor(s),
                    ),
                  ),
                ),
                for (var i = 0; i < labels.length; i++)
                  Positioned(
                    left: lefts[i],
                    width: widths[i],
                    top: 0,
                    bottom: 0,
                    child: _segment(context, i, style, duration),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (!expand) return pill(natural);
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - 2 * _padding;
        final each = available / labels.length;
        return pill([for (final _ in labels) each]);
      },
    );
  }

  Widget _segment(
    BuildContext context,
    int i,
    TextStyle? style,
    Duration duration,
  ) {
    final s = Theme.of(context).colorScheme;
    final selected = i == selectedIndex;
    void onTap() => onChanged(i);
    return Semantics(
      selected: selected,
      button: true,
      label: labels[i],
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: _curve,
              style: (style ?? const TextStyle()).copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? s.onSurface : s.onSurfaceVariant,
              ),
              // With large text the label shrinks to fit rather than being
              // cut ("Expen…").
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(labels[i], maxLines: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
