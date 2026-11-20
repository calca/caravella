import 'package:material_ui/material_ui.dart';

import 'floating_nav_bar.dart';

/// The navigation of [FloatingNavBar] for wide windows: a column on the
/// start side, with the primary [action] on top.
///
/// [extended] (expanded windows) shows each destination as icon + label on
/// one row and the action as a pill with its label; otherwise (medium) it is
/// a rail: icons with their label underneath, the action a rounded square.
/// Same items, colors and action as the floating bar, so switching between
/// the two (rotating, resizing a window) keeps everything in place.
class SideNav extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final FloatingNavAction? action;
  final bool extended;

  const SideNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.action,
    this.extended = false,
  });

  static const double railWidth = 96;
  static const double extendedWidth = 248;

  @override
  Widget build(BuildContext context) {
    // It sits beside the pages' Scaffolds, not in one: its own Material for
    // ink, scrollable for short windows (a phone in landscape).
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: extended ? extendedWidth : railWidth,
        child: SafeArea(
          right: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              extended ? 16 : 12,
              24,
              extended ? 8 : 12,
              24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: extended
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.center,
                children: [
                  if (action != null) ...[
                    _SideAction(action: action!, extended: extended),
                    const SizedBox(height: 28),
                  ],
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(height: extended ? 4 : 12),
                    _SideDestination(
                      item: items[i],
                      selected: i == selectedIndex,
                      extended: extended,
                      onTap: () => onSelected(i),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideDestination extends StatelessWidget {
  final FloatingNavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _SideDestination({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final fill = selected ? FloatingNavBar.selectedColor(s) : null;
    final iconColor = selected ? s.onSurface : s.onSurfaceVariant;
    final icon = Icon(
      selected ? item.selectedIcon : item.icon,
      size: 24,
      color: iconColor,
    );
    final label = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          (extended ? theme.textTheme.titleSmall : theme.textTheme.labelMedium)
              ?.copyWith(
                color: s.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
    );
    // One node per destination, selected state included, as in the bar.
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: extended
          ? Material(
              color: fill ?? Colors.transparent,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        icon,
                        const SizedBox(width: 14),
                        Expanded(child: label),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 32,
                      decoration: ShapeDecoration(
                        color: fill,
                        shape: const StadiumBorder(),
                      ),
                      alignment: Alignment.center,
                      child: icon,
                    ),
                    const SizedBox(height: 4),
                    label,
                  ],
                ),
              ),
            ),
    );
  }
}

class _SideAction extends StatelessWidget {
  final FloatingNavAction action;
  final bool extended;

  const _SideAction({required this.action, required this.extended});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final enabled = action.onPressed != null;
    final fg = enabled ? s.onPrimary : s.onSurface.withValues(alpha: 0.38);
    return Tooltip(
      message: extended ? '' : action.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: action.label,
        onTap: action.onPressed,
        excludeSemantics: true,
        child: Material(
          color: enabled ? s.primary : s.onSurface.withValues(alpha: 0.12),
          shape: extended
              ? const StadiumBorder()
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: action.onPressed,
            child: SizedBox(
              width: extended ? null : 64,
              height: extended ? 56 : 64,
              child: extended
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(action.icon, size: 24, color: fg),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              action.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Icon(action.icon, size: 28, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
