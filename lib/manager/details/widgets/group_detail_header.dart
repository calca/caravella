import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../../home/cards/widgets/group_meta_line.dart';
import 'group_detail_top_bar.dart';

/// The top of the group page: a block in the group's tint ([GroupLook]:
/// neutral grey without a color; under a photo, the photo melting into its
/// own tone, [PhotoTone]) from the top of the screen, under the round
/// buttons of [GroupDetailTopBar], with the big faint type icon below them
/// and the [header] in the tint's text color.
class GroupHeaderBand extends StatelessWidget {
  final ExpenseGroup group;

  /// The title block, in the given text color.
  final Widget Function(Color foreground) header;

  final double topInset;

  const GroupHeaderBand({
    super.key,
    required this.group,
    required this.header,
    required this.topInset,
  });

  /// The group's resolved color, when it has one and no photo.
  static Color? colorOf(ExpenseGroup group, ColorScheme s) =>
      photoOf(group) != null ? null : GroupLook.colorOf(group, s);

  static String? photoOf(ExpenseGroup group) => GroupLook.photoOf(group);

  /// The band's tint and its text color, for a group without a photo.
  static (Color, Color) lookOf(ExpenseGroup group, ColorScheme s) {
    final look = GroupLook.of(colorOf(group, s), s.brightness);
    return (look.tint, look.onTint);
  }

  /// Under the top bar: where the band's content and the big icon start.
  double get _barBottom => topInset + GroupDetailTopBar.height;

  static const double _markSize = 170;
  static const double _markOverflow = 0.24;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final photo = photoOf(group);
    final type = group.groupType ?? ExpenseGroupType.other;

    Widget band(Color background, Color fg, Color? markColor) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Stack(
          children: [
            Positioned.fill(
              child: photo != null
                  ? PhotoBand(
                      path: photo,
                      tone: background,
                      photoHeight: _barBottom + 150,
                    )
                  : ColoredBox(color: background),
            ),
            if (markColor != null)
              TypeMark(
                icon: type.icon,
                size: _markSize,
                color: markColor,
                overflow: _markOverflow,
              ).positioned(top: _barBottom + _markOverflow * _markSize),
            Padding(
              padding: EdgeInsets.fromLTRB(
                30,
                _barBottom + (photo != null ? 96 : 56),
                30,
                22,
              ),
              child: header(fg),
            ),
          ],
        ),
      ),
    );
    if (photo == null) {
      final look = GroupLook.of(colorOf(group, s), s.brightness);
      return band(look.tint, look.onTint, look.mark);
    }
    return PhotoToneBuilder(
      path: photo,
      builder: (context, tone) => band(tone.tone, tone.onTone, null),
    );
  }
}

/// Title block of the group page: the group name, the line of favorite,
/// type, dates and people ([GroupMetaLine], as on Home's card), and the key
/// figures (total, today).
class GroupDetailHeader extends StatelessWidget {
  final ExpenseGroup group;
  final Color foreground;

  /// "Today" for the figures; now when null (tests set it).
  final DateTime? today;

  const GroupDetailHeader({
    super.key,
    required this.group,
    required this.foreground,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            group.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // The same line as on Home's card, with the people; the sync state
        // is on the top bar's round sync button.
        GroupMetaLine(
          group: group,
          foreground: foreground,
          showShared: false,
          showPeople: true,
        ),
        const SizedBox(height: 14),
        // The budget is in the statistics (its card), not here.
        FigureRow(
          color: foreground,
          items: [
            FigureRowItem(
              label: gloc.group_total,
              value: group.getTotalExpenses(),
              currency: group.currency,
            ),
            FigureRowItem(
              label: gloc.today,
              value: group.getTodaySpendingSync(today),
              currency: group.currency,
            ),
          ],
        ),
      ],
    );
  }
}
