import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';

/// The app's back button: a raised round button with a rounded arrow in the
/// theme's text color (Flutter's [BackButton] took its color from the app
/// bar theme, wrong on these pages in the dark theme).
class RoundBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const RoundBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Material(
      color: s.raisedSurface,
      shape: const CircleBorder(),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: s.onSurface,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

/// A raised round icon button matching [RoundBackButton] (e.g. share and
/// delete at the top of a page). [destructive] uses the error color.
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool destructive;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Material(
      color: s.raisedSurface,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        color: destructive ? s.error : s.onSurface,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

/// One entry of a [RoundMenuButton]'s menu. [destructive] shows it in the
/// error color (e.g. Delete).
class RoundMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const RoundMenuItem(
    this.icon,
    this.label,
    this.onTap, {
    this.destructive = false,
  });
}

/// A round ⋯ matching [RoundBackButton], opening a menu with the less
/// frequent actions of a page (the group page, an expense), whose end lines
/// up with the button. [background] defaults to the raised surface.
class RoundMenuButton extends StatelessWidget {
  final List<RoundMenuItem> items;
  final String tooltip;
  final Color? background;

  const RoundMenuButton({
    super.key,
    required this.items,
    required this.tooltip,
    this.background,
  });

  /// Items at least this wide give the menu a known width, so its end lines
  /// up with the button's (and the page margin) instead of running to the
  /// screen edge.
  static const double menuWidth = 248.0;
  static const double _buttonSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return MenuAnchor(
      alignmentOffset: const Offset(_buttonSize - menuWidth, 4),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(s.raisedSurface),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            style: MenuItemButton.styleFrom(
              minimumSize: const Size(menuWidth, 48),
              foregroundColor: item.destructive ? s.error : null,
              iconColor: item.destructive ? s.error : null,
            ),
            leadingIcon: Icon(item.icon),
            onPressed: item.onTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Text(item.label),
            ),
          ),
      ],
      builder: (context, controller, _) => Material(
        color: background ?? s.raisedSurface,
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(Icons.more_horiz_rounded),
          color: s.onSurface,
          tooltip: tooltip,
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    );
  }
}
