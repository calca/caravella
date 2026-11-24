import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../../sync/group_sync_badge.dart';

/// One entry of the group page's ⋯ menu.
class GroupMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const GroupMenuItem(this.icon, this.label, this.onTap);
}

/// The group page's top bar, over the header band: round back, search and ⋯
/// buttons at rest. As content scrolls under it the bar fills with the
/// band's own [tint] ([fill], 0 to 1), so bar and band stay one color with
/// no grey strip between them, and shows [title] when [titleVisible].
class GroupDetailTopBar extends StatelessWidget {
  static const double height = 64.0;

  final String title;

  /// How much of [tint] the bar has: 0 at rest (see-through), 1 once the
  /// band has scrolled under it.
  final double fill;
  final bool titleVisible;

  /// The band's color (the group's tint, or its photo's tone) and the text
  /// color on it: icons and title use [foreground] at every [fill].
  final Color tint;
  final Color foreground;

  /// Under a photo the round buttons sit on the photo itself, not on its
  /// tone: they get a stronger veil of the tone so the icons stay legible.
  final bool overPhoto;

  /// Null hides the search button (a group with no expenses).
  final VoidCallback? onSearch;
  final List<GroupMenuItem> menuItems;

  /// A shared group: a round sync button before search, with the dot of
  /// how its sync is doing, opening the sync page ([onSync]).
  final ExpenseGroup? syncGroup;
  final VoidCallback? onSync;

  const GroupDetailTopBar({
    super.key,
    required this.title,
    required this.fill,
    required this.titleVisible,
    required this.tint,
    required this.foreground,
    this.overPhoto = false,
    required this.onSearch,
    required this.menuItems,
    this.syncGroup,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final f = fill.clamp(0.0, 1.0);
    // Faint circles in the band's own colors, not white ones: white circles
    // shouted over a dark color or photo. They fade out as the bar fills.
    final buttonBackground = overPhoto
        ? tint.withValues(alpha: 0.6 * (1 - f))
        : foreground.withValues(alpha: 0.16 * (1 - f));

    Widget roundButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
    }) => Material(
      color: buttonBackground,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        color: foreground,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );

    return Container(
      color: tint.withValues(alpha: f),
      padding: EdgeInsets.fromLTRB(16, topInset + 4, 16, 4),
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
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (syncGroup case final group?) ...[
              GroupSyncBadge(
                group: group,
                round: true,
                background: buttonBackground,
                foreground: foreground,
                onTap: onSync,
              ),
              const SizedBox(width: 8),
            ],
            if (onSearch case final search?) ...[
              roundButton(
                icon: Icons.search_rounded,
                tooltip: gloc.search_expenses,
                onPressed: search,
              ),
              const SizedBox(width: 8),
            ],
            _GroupMenuButton(
              background: buttonBackground,
              foreground: foreground,
              items: menuItems,
            ),
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
  final Color foreground;
  final List<GroupMenuItem> items;

  const _GroupMenuButton({
    required this.background,
    required this.foreground,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => RoundMenuButton(
    background: background,
    foreground: foreground,
    tooltip: gen.AppLocalizations.of(context).more_options,
    items: [
      for (final item in items)
        RoundMenuItem(item.icon, item.label, item.onTap),
    ],
  );
}
