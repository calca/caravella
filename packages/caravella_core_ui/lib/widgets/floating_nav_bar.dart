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
/// tonal pill and its label slides out next to the icon. Colors are neutral
/// (derived from the surface roles) so the bar doesn't compete with content;
/// only the [action] uses the primary color.
///
/// The widget sizes itself to its content and adds the bottom safe-area
/// inset; place it with `Align(alignment: Alignment.bottomCenter)` over the
/// page and reserve [FloatingNavBar.reservedHeight] at the bottom of
/// scrollable content so the last items can scroll clear of it.
class FloatingNavBar extends StatelessWidget {
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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                color: pillColor(s),
                shape: const StadiumBorder(),
                shadows: shadow,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        _Destination(
                          item: items[i],
                          selected: i == selectedIndex,
                          onTap: () => onSelected(i),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 10),
              _ActionButton(action: action!, shadow: shadow),
            ],
          ],
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _Destination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
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
          child: AnimatedContainer(
            duration: FloatingNavBar._duration,
            curve: FloatingNavBar._curve,
            height: 52,
            constraints: const BoxConstraints(minWidth: 56),
            padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 16),
            decoration: ShapeDecoration(
              color: selected
                  ? FloatingNavBar.selectedColor(s)
                  : Colors.transparent,
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected ? s.onSurface : s.onSurfaceVariant,
                ),
                // The label slides out next to the selected icon.
                AnimatedSize(
                  duration: FloatingNavBar._duration,
                  curve: FloatingNavBar._curve,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: s.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
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
