import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// One destination of a [FloatingNavBar].
class FloatingNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// The round button next to a [FloatingNavBar]: the primary action of the
/// selected destination (e.g. "new expense" on Home, "new group" on Groups).
class FloatingNavAction {
  final IconData icon;

  /// Spoken by screen readers and shown as tooltip.
  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  const FloatingNavAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

/// Floating pill navigation drawn over the page content, with an optional
/// round [action] beside it.
///
/// Unselected destinations show only their icon; the selected one sits on a
/// tonal pill and its label slides out next to the icon. Selecting another
/// destination slides the pill over to it while the labels swap, and the new
/// icon gives a small bounce (instant when the system disables animations). Colors are neutral
/// (derived from the surface roles) so the bar doesn't compete with content;
/// only the [action] uses the primary color.
///
/// The widget sizes itself to its content and adds the bottom safe-area
/// inset; place it with `Align(alignment: Alignment.bottomCenter)` over the
/// page and reserve [FloatingNavBar.reservedHeight] at the bottom of
/// scrollable content so the last items can scroll clear of it.
class FloatingNavBar extends StatefulWidget {
  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final FloatingNavAction? action;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.action,
  });

  /// Height of the bar plus its bottom margin, excluding the safe-area inset.
  static const double reservedHeight = 64 + 12 + 12;

  static const Duration _duration = Duration(milliseconds: 320);
  static const Curve _curve = Curves.easeOutCubic;

  /// Pill background: white on the light page, a lifted grey in dark.
  static Color pillColor(ColorScheme s) => s.brightness == Brightness.dark
      ? s.surfaceContainerHighest
      : s.surfaceContainerLowest;

  /// Selected-destination fill: a light tonal step above [pillColor].
  static Color selectedColor(ColorScheme s) =>
      Color.alphaBlend(s.onSurface.withValues(alpha: 0.11), pillColor(s));

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

/// Destination geometry: unselected = icon in a 56-wide slot; selected = 20
/// padding, icon, 8 gap, label, 20 padding.
const double _slotHeight = 52;
const double _iconSize = 24;
const double _unselectedWidth = 56;
const double _gap = 4;

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  // One animation drives everything — slot widths, the sliding indicator,
  // label reveal, icon bounce — so they never drift apart.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FloatingNavBar._duration,
    value: 1,
  );
  int? _previous;

  @override
  void didUpdateWidget(FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _controller.value = 1;
    } else {
      _previous = oldWidget.selectedIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final dark = s.brightness == Brightness.dark;
    final shadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.45 : 0.10),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ];
    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      color: s.onSurface,
      fontWeight: FontWeight.w600,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    final labelWidths = [
      for (final item in widget.items)
        (TextPainter(
          text: TextSpan(text: item.label, style: labelStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: textScaler,
        )..layout()).width.ceilToDouble(),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                color: FloatingNavBar.pillColor(s),
                shape: const StadiumBorder(),
                shadows: shadow,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) =>
                        _buildSlots(context, labelWidths, labelStyle),
                  ),
                ),
              ),
            ),
            if (widget.action != null) ...[
              const SizedBox(width: 10),
              _ActionButton(action: widget.action!, shadow: shadow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlots(
    BuildContext context,
    List<double> labelWidths,
    TextStyle? labelStyle,
  ) {
    final s = Theme.of(context).colorScheme;
    final t = _controller.value;
    final c = FloatingNavBar._curve.transform(t);
    final selected = widget.selectedIndex;

    // How "selected" each slot is right now (0..1).
    double weight(int i) => i == selected
        ? c
        : i == _previous
        ? 1 - c
        : 0;
    double fullWidth(int i) => 2 * 20 + _iconSize + 8 + labelWidths[i];
    final weights = [for (var i = 0; i < widget.items.length; i++) weight(i)];
    final widths = [
      for (var i = 0; i < widget.items.length; i++)
        _unselectedWidth + weights[i] * (fullWidth(i) - _unselectedWidth),
    ];
    final lefts = <double>[];
    var x = 0.0;
    for (final w in widths) {
      lefts.add(x);
      x += w + _gap;
    }

    // The indicator slides from the previous slot to the selected one,
    // following both as they resize.
    final from = _previous ?? selected;
    final indicatorLeft = lefts[from] + (lefts[selected] - lefts[from]) * c;
    final indicatorWidth = widths[from] + (widths[selected] - widths[from]) * c;

    return SizedBox(
      width: x - _gap,
      height: _slotHeight,
      child: Stack(
        children: [
          Positioned(
            left: indicatorLeft,
            width: indicatorWidth,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: FloatingNavBar.selectedColor(s),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          for (var i = 0; i < widget.items.length; i++)
            Positioned(
              left: lefts[i],
              width: widths[i],
              top: 0,
              bottom: 0,
              child: _Destination(
                item: widget.items[i],
                selected: i == selected,
                weight: weights[i],
                // A small bounce of the icon that just got selected.
                iconScale: i == selected && _previous != null
                    ? 1 + 0.18 * math.sin(math.pi * t)
                    : 1,
                labelStyle: labelStyle,
                onTap: () => widget.onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  final FloatingNavItem item;
  final bool selected;

  /// 0 = unselected look, 1 = selected look (label fully out).
  final double weight;
  final double iconScale;
  final TextStyle? labelStyle;
  final VoidCallback onTap;

  const _Destination({
    required this.item,
    required this.selected,
    required this.weight,
    required this.iconScale,
    required this.labelStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    // excludeSemantics drops the InkWell's own tap action, so hand it to the
    // merged node or screen readers couldn't activate the destination.
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: selected ? '' : item.label,
        excludeFromSemantics: true,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: iconScale,
                child: Icon(
                  // The filled icon comes in early in the bounce.
                  weight > 0.3 ? item.selectedIcon : item.icon,
                  size: _iconSize,
                  color: Color.lerp(s.onSurfaceVariant, s.onSurface, weight),
                ),
              ),
              // The label slides out next to the selected icon.
              if (weight > 0)
                ClipRect(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: weight,
                    child: Opacity(
                      opacity: weight,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          softWrap: false,
                          style: labelStyle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final FloatingNavAction action;
  final List<BoxShadow> shadow;

  const _ActionButton({required this.action, required this.shadow});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final enabled = action.onPressed != null;
    return Tooltip(
      message: action.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: action.label,
        onTap: action.onPressed,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: enabled ? shadow : null,
          ),
          child: Material(
            color: enabled ? s.primary : s.onSurface.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: action.onPressed,
              child: SizedBox(
                width: 64,
                height: 64,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    action.icon,
                    key: ValueKey(action.icon),
                    size: 30,
                    color: enabled
                        ? s.onPrimary
                        : s.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
