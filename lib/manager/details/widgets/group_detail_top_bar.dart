import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// One entry of the group page's ⋯ menu.
class GroupMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const GroupMenuItem(this.icon, this.label, this.onTap);
}

/// The group page's top bar, over the header band: round back, search and ⋯
/// buttons at rest; once content scrolls under it ([opaque]) it takes the
/// page color and shows [title] when [titleVisible].
class GroupDetailTopBar extends StatelessWidget {
  static const double height = 64.0;

  final String title;
  final bool opaque;
  final bool titleVisible;

  /// Title color while [opaque] is false (the group color's contrast).
  final Color bandForeground;
  final Color pageColor;

  /// Null hides the search button (a group with no expenses).
  final VoidCallback? onSearch;
  final List<GroupMenuItem> menuItems;

  const GroupDetailTopBar({
    super.key,
    required this.title,
    required this.opaque,
    required this.titleVisible,
    required this.bandForeground,
    required this.pageColor,
    required this.onSearch,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final buttonBackground = opaque ? Colors.transparent : s.raisedSurface;

    Widget roundButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
    }) => Material(
      color: buttonBackground,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        color: s.onSurface,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );

    // At rest over card style A's cover, the buttons sit inside it (the
    // cover is 16 from the edges); otherwise near the edges.
    final side = !opaque && GroupCardStyle.current.value == GroupCardStyle.a
        ? 24.0
        : 12.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: opaque ? pageColor : pageColor.withValues(alpha: 0),
      padding: EdgeInsets.fromLTRB(side, topInset + 4, side, 4),
      child: SizedBox(
        height: height - 8,
        child: Row(
          children: [
            roundButton(
              icon: Icons.arrow_back_rounded,
              tooltip: gloc.accessibility_back_button,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedOpacity(
                opacity: titleVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: opaque ? s.onSurface : bandForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (onSearch case final search?) ...[
              roundButton(
                icon: Icons.search_rounded,
                tooltip: gloc.search_expenses,
                onPressed: search,
              ),
              const SizedBox(width: 8),
            ],
            _GroupMenuButton(background: buttonBackground, items: menuItems),
          ],
        ),
      ),
    );
  }
}

/// The group page's "more" button: a round ⋯ opening a menu with the less
/// frequent actions, so the top bar keeps only back and search.
class _GroupMenuButton extends StatelessWidget {
  final Color background;
  final List<GroupMenuItem> items;

  const _GroupMenuButton({required this.background, required this.items});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    // Items at least [menuWidth] wide give the menu a known width, so its end
    // lines up with the button's (and the page margin) instead of running to
    // the screen edge.
    const menuWidth = 248.0;
    const buttonSize = 48.0;
    return MenuAnchor(
      alignmentOffset: const Offset(buttonSize - menuWidth, 4),
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
        color: background,
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(Icons.more_horiz_rounded),
          color: s.onSurface,
          tooltip: gloc.more_options,
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    );
  }
}
