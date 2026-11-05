import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';
import 'currency_display.dart';
import 'photo_veil.dart';

/// What a group looks like on its card: background, type icon, name, a line
/// below it and the total. Shared by the Groups page and the creation
/// wizard's preview, so a new group looks the same before and after saving.
/// The caller adds the outline, the clipping and any tap.
///
/// Every card has one background treatment:
/// - **photo**: full color on top, melting into the surface the text sits on
///   ([PhotoVeil], like the Home card and the group page);
/// - **color**: the palette color, with contrasting text;
/// - **neither**: the raised surface of the Home card.
///
/// Cards without a photo show the [icon] top-left, so they don't look empty.
class GroupCardFace extends StatelessWidget {
  final String title;

  /// The line under the name.
  final String? subtitle;

  final double total;
  final String currency;

  /// The group's photo; [color] shows when there's none or it can't be found.
  final String? photoPath;
  final Color? color;

  final IconData icon;

  /// The wide card (favorite group, wizard) instead of a grid tile.
  final bool wide;

  /// The wide card at [compactHeight]: same text, smaller icon and margins.
  final bool compact;

  /// Above the name on the wide card, with a heart: the favorite group.
  final String? favoriteLabel;

  const GroupCardFace({
    super.key,
    required this.title,
    required this.total,
    required this.currency,
    required this.icon,
    this.subtitle,
    this.photoPath,
    this.color,
    this.wide = false,
    this.compact = false,
    this.favoriteLabel,
  });

  static const double wideHeight = 196;
  static const double compactHeight = 120;

  static BorderRadius borderRadiusFor({required bool wide}) =>
      BorderRadius.circular(wide ? 28 : 24);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final path = photoPath;
    final hasPhoto = path != null && path.isNotEmpty && File(path).existsSync();
    final background = hasPhoto ? null : color;
    final Color fg = background != null
        ? ExpenseGroupColorPalette.getContrastingTextColor(background)
        : s.onSurface;
    final Color fgSecondary = fg.withValues(alpha: 0.8);
    final spot = compact
        ? PhotoVeilSpot.groupsWideCardCompact
        : wide
        ? PhotoVeilSpot.groupsWideCard
        : PhotoVeilSpot.groupsCard;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
        : EdgeInsets.all(wide ? 18 : 14);
    final iconBox = compact ? 32.0 : (wide ? 44.0 : 40.0);
    final iconSize = compact ? 18.0 : (wide ? 24.0 : 22.0);
    final line = subtitle;

    final amount = CurrencyDisplay(
      value: total,
      currency: currency,
      valueFontSize: wide ? 26 : 22,
      currencyFontSize: 14,
      alignment: wide ? MainAxisAlignment.end : MainAxisAlignment.start,
      showDecimals: true,
      color: fg,
    );

    final content = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (favoriteLabel case final label?) ...[
                      Row(
                        children: [
                          Icon(Icons.favorite_rounded, size: 16, color: fg),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: fgSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (line != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: fgSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              amount,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              if (line != null) ...[
                const SizedBox(height: 4),
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: fgSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 2),
              amount,
            ],
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasPhoto)
          PhotoVeil(
            path: path,
            // The same raised surface as the cards without a photo.
            color: s.raisedSurface,
            solidExtent: spot.solidExtent,
            fadeExtent: spot.fadeExtent,
          )
        else
          ColoredBox(color: background ?? s.raisedSurface),
        if (!hasPhoto)
          Padding(
            padding: padding,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fg.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: iconSize, color: fg),
              ),
            ),
          ),
        Padding(padding: padding, child: content),
      ],
    );
  }
}
