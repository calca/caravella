import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../../sync/group_sync_badge.dart';
import '../../budget/budget_detail_sheet.dart';
import '../../group/group_type/group_type_localization.dart';
import '../pages/tabs/usecase/date_range_formatter.dart';
import 'group_detail_top_bar.dart';

/// The top of the group page, under the round buttons of
/// [GroupDetailTopBar], following [GroupCardStyle.current]:
/// - **A**: the photo, the color or neutral grey in a rounded cover (16 from
///   the edges) with the type chip at its bottom and the big faint type icon
///   under the buttons; the [header] below it on the page color;
/// - **B**: a block in the group's tint (under a photo, the photo's own
///   tone) from the top of the screen, with the chip and the [header] on it.
class GroupHeaderBand extends StatelessWidget {
  final ExpenseGroup group;

  /// The title block, in the given text color.
  final Widget Function(Color foreground) header;

  final double topInset;

  /// Overrides [GroupCardStyle.current] (tests).
  final GroupCardStyle? style;

  const GroupHeaderBand({
    super.key,
    required this.group,
    required this.header,
    required this.topInset,
    this.style,
  });

  /// The group's resolved color, when it has one and no photo.
  static Color? colorOf(ExpenseGroup group, ColorScheme s) =>
      photoOf(group) != null ? null : GroupLook.colorOf(group, s);

  static String? photoOf(ExpenseGroup group) => GroupLook.photoOf(group);

  /// Text color for the top bar's title over the band, before it turns
  /// opaque.
  static Color foregroundOf(ExpenseGroup group, ColorScheme s) {
    if (photoOf(group) != null) return s.onSurface;
    final look = GroupLook.of(colorOf(group, s), s.brightness);
    return GroupCardStyle.current.value == GroupCardStyle.b
        ? look.onTint
        : ExpenseGroupColorPalette.getContrastingTextColor(look.cover);
  }

  /// Under the top bar: where the cover's content and the big icon start.
  double get _barBottom => topInset + GroupDetailTopBar.height;

  static const double _markSize = 170;
  static const double _markOverflow = 0.24;

  @override
  Widget build(BuildContext context) {
    if (style case final style?) return _build(context, style);
    return GroupCardStyleBuilder(builder: _build);
  }

  Widget _build(BuildContext context, GroupCardStyle style) {
    final s = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final photo = photoOf(group);
    final look = GroupLook.of(colorOf(group, s), s.brightness);
    final type = group.groupType ?? ExpenseGroupType.other;
    final chip = TypeChip(
      icon: type.icon,
      label: GroupTypeLocalization.typeName(gloc, type),
    );
    Widget mark(Color color) => TypeMark(
      icon: type.icon,
      size: _markSize,
      color: color,
      overflow: _markOverflow,
    ).positioned(top: _barBottom + _markOverflow * _markSize);

    if (style == GroupCardStyle.a) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              height: _barBottom + 132,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (photo != null)
                      GroupCoverPhoto(path: photo, fallback: look.cover)
                    else ...[
                      ColoredBox(color: look.cover),
                      mark(look.coverMark),
                    ],
                    Positioned(left: 14, bottom: 14, child: chip),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 16, 30, 18),
            child: header(s.onSurface),
          ),
        ],
      );
    }

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
            if (markColor != null) mark(markColor),
            Padding(
              padding: EdgeInsets.fromLTRB(30, _barBottom + 52, 30, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [chip, const SizedBox(height: 14), header(fg)],
              ),
            ),
          ],
        ),
      ),
    );
    if (photo == null) return band(look.tint, look.onTint, look.tintMark);
    return PhotoToneBuilder(
      path: photo,
      builder: (context, tone) => band(tone.tone, tone.onTone, null),
    );
  }
}

/// Title block of the group page: dates · people, the group name, and the
/// key figures (total, today, per person) in small cards.
class GroupDetailHeader extends StatelessWidget {
  final ExpenseGroup group;
  final Color foreground;

  /// Opens the group's sync page from the "Shared" badge.
  final VoidCallback? onOpenSync;

  /// Opens the budget sheet from "Today", when the group has a budget.
  final VoidCallback? onOpenBudget;

  /// "Today" for the figures; now when null (tests set it).
  final DateTime? today;

  const GroupDetailHeader({
    super.key,
    required this.group,
    required this.foreground,
    this.onOpenSync,
    this.onOpenBudget,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final people = gloc.participant_count(group.participants.length);
    final dates = (group.startDate != null || group.endDate != null)
        ? formatDateRange(
            start: group.startDate,
            end: group.endDate,
            locale: Localizations.localeOf(context),
          )
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Favorite moved to the ⋯ menu: the heart here shows the state.
            if (group.pinned) ...[
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: foreground,
                semanticLabel: gloc.pin,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                dates == null ? people : '$dates · $people',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (group.syncEnabled) ...[
              const SizedBox(width: 8),
              GroupSyncBadge(
                group: group,
                background: foreground.withValues(alpha: 0.1),
                foreground: foreground,
                onTap: onOpenSync,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
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
        const SizedBox(height: 14),
        Builder(
          builder: (context) {
            final spentToday = group.getTodaySpendingSync(today);
            // With a budget, a ring of how today is going against what can
            // be spent today; tapping "Today" opens the budget.
            final budget = BudgetStatus.of(
              group,
              today: today,
              firstDayOfWeek: firstDayOfWeekOf(context),
            );
            final locale = Localizations.localeOf(context);
            String money(double v) =>
                CurrencyDisplay.formatLocalizedText(v, group.currency, locale);
            return FigureRow(
              color: foreground,
              items: [
                FigureRowItem(
                  label: gloc.group_total,
                  value: group.getTotalExpenses(),
                  currency: group.currency,
                ),
                FigureRowItem(
                  label: gloc.today,
                  value: spentToday,
                  currency: group.currency,
                  trailing: switch (budget?.todayFraction) {
                    final f? => BudgetRing(
                      fraction: f,
                      over: budget!.overToday,
                      size: 24,
                      strokeWidth: 3,
                    ),
                    null => null,
                  },
                  onTap: budget == null ? null : onOpenBudget,
                  semanticLabel: switch (budget) {
                    null => null,
                    BudgetStatus(todayShare: final share?)
                        when budget.overToday =>
                      gloc.budget_today_over(money(spentToday), money(share)),
                    BudgetStatus(todayShare: final share?) =>
                      gloc.budget_today_within(money(spentToday), money(share)),
                    _ => gloc.budget_today_open(money(spentToday)),
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
