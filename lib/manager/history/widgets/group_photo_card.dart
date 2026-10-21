import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../../details/pages/expense_group_detail_page.dart';
import '../../details/pages/tabs/usecase/date_range_formatter.dart';
import 'group_options.dart';

/// Card of the Groups page: a grid tile, or the wide card used for the
/// favorite group at the top.
///
/// Every card shares one background treatment so they look alike:
/// - **photo**: full color on top, melting into the surface the text sits on
///   ([PhotoVeil], like the Home card and the group page);
/// - **color**: the palette color, with contrasting text;
/// - **neither**: the raised surface of the Home card, with the group type
///   icon.
///
/// Tap opens the group; long press opens [showGroupOptionsSheet].
class GroupPhotoCard extends StatelessWidget {
  final ExpenseGroup group;
  final bool wide;
  final Future<void> Function(String groupId, bool archived) onArchiveToggle;
  final VoidCallback? onChanged;

  const GroupPhotoCard({
    super.key,
    required this.group,
    required this.onArchiveToggle,
    this.onChanged,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    final file = group.file;
    final hasPhoto = file != null && file.isNotEmpty && File(file).existsSync();
    final Color? color = hasPhoto || group.color == null
        ? null
        : ExpenseGroupColorPalette.isLegacyColorValue(group.color)
        ? Color(group.color!)
        : ExpenseGroupColorPalette.resolveColor(group.color, s);
    final Color fg = color != null
        ? ExpenseGroupColorPalette.getContrastingTextColor(color)
        : s.onSurface;
    final Color fgSecondary = fg.withValues(alpha: 0.8);

    final people = gloc.participant_count(group.participants.length);
    final dates = (group.startDate != null || group.endDate != null)
        ? formatDateRange(
            start: group.startDate,
            end: group.endDate,
            locale: Localizations.localeOf(context),
          )
        : null;
    final total = group.getTotalExpenses();

    final background = hasPhoto
        // Photo in full color on top, melting into the surface the text
        // sits on.
        ? PhotoVeil(
            path: file,
            // The same raised surface as the cards without a photo.
            color: s.raisedSurface,
            solidExtent: wide ? 72 : 84,
            fadeExtent: wide ? 100 : 110,
          )
        // No photo or color: the same raised surface as the Home card.
        : ColoredBox(color: color ?? s.raisedSurface);

    // Cards without a photo show the group type icon top-left, so they don't
    // look empty.
    final typeIcon = hasPhoto
        ? null
        : Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: wide ? 44 : 40,
              height: wide ? 44 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fg.withValues(alpha: 0.12),
              ),
              child: Icon(
                (group.groupType ?? ExpenseGroupType.other).icon,
                size: wide ? 24 : 22,
                color: fg,
              ),
            ),
          );

    final amount = CurrencyDisplay(
      value: total,
      currency: group.currency,
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
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded, size: 16, color: fg),
                        const SizedBox(width: 6),
                        Text(
                          gloc.pin,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: fgSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dates == null ? people : '$dates · $people',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: fgSecondary,
                      ),
                    ),
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
                group.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                people,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: fgSecondary),
              ),
              const SizedBox(height: 2),
              amount,
            ],
          );

    void open() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseGroupDetailPage(trip: group)),
    );
    void options() => showGroupOptionsSheet(
      context,
      trip: group,
      onArchiveToggle: onArchiveToggle,
      onDelete: onChanged,
      onPin: onChanged,
    );

    return CardOutline(
      borderRadius: BorderRadius.circular(wide ? 28 : 24),
      child: Semantics(
        button: true,
        label: [
          group.title,
          if (group.pinned) gloc.pin,
          ?dates,
          people,
          '${total.toStringAsFixed(2)} ${group.currency}',
        ].join(', '),
        onTap: open,
        onLongPress: options,
        excludeSemantics: true,
        child: Material(
          borderRadius: BorderRadius.circular(wide ? 28 : 24),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: open,
            onLongPress: options,
            child: Stack(
              fit: StackFit.expand,
              children: [
                background,
                if (typeIcon != null)
                  Padding(
                    padding: EdgeInsets.all(wide ? 18 : 14),
                    child: typeIcon,
                  ),
                Padding(
                  padding: EdgeInsets.all(wide ? 18 : 14),
                  child: content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
