import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../../sync/group_sync_badge.dart';
import '../../budget/budget_detail_sheet.dart';
import '../pages/tabs/usecase/date_range_formatter.dart';

/// The group's photo or color behind the top of its page, melting into
/// [pageColor] at the bottom. A photo (as on the Home and Groups cards) is in
/// full color at the top and melts into the page color, where dates, title
/// and figure cards keep the theme's colors; a color does the same
/// ([ColorVeil]).
class GroupHeaderBand extends StatelessWidget {
  final ExpenseGroup group;
  final Color pageColor;

  const GroupHeaderBand({
    super.key,
    required this.group,
    required this.pageColor,
  });

  /// The group's resolved color, when it has one and no photo.
  static Color? colorOf(ExpenseGroup group, ColorScheme s) {
    if (photoOf(group) != null || group.color == null) return null;
    return ExpenseGroupColorPalette.isLegacyColorValue(group.color)
        ? Color(group.color!)
        : ExpenseGroupColorPalette.resolveColor(group.color, s);
  }

  static String? photoOf(ExpenseGroup group) {
    final file = group.file;
    return file != null && file.isNotEmpty && File(file).existsSync()
        ? file
        : null;
  }

  /// Extra room above the title with a photo or a color, so it shows.
  static const double photoExtraTop = 96;

  /// Text color for the top bar over the band (the title sits on the page
  /// color, in the theme's text color).
  static Color foregroundOf(ExpenseGroup group, ColorScheme s) {
    final color = colorOf(group, s);
    return color == null
        ? s.onSurface
        : ExpenseGroupColorPalette.getContrastingTextColor(color);
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final photo = photoOf(group);
    final color = colorOf(group, s);
    if (photo == null && color == null) return ColoredBox(color: pageColor);

    if (photo != null) {
      // Dates, title and figure cards on the page color; the photo melts
      // into it above them, the same all the way up (no shade under the
      // top bar).
      return PhotoVeil(
        path: photo,
        color: pageColor,
        solidExtent: PhotoVeilSpot.groupPage.solidExtent,
        fadeExtent: PhotoVeilSpot.groupPage.fadeExtent,
      );
    }
    return ColorVeil(
      color: color!,
      surface: pageColor,
      solidExtent: PhotoVeilSpot.groupPage.solidExtent,
      fadeExtent: PhotoVeilSpot.groupPage.fadeExtent,
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
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final total = _Figure(
              label: gloc.group_total,
              value: group.getTotalExpenses(),
              currency: group.currency,
              big: true,
            );
            final spentToday = group.getTodaySpendingSync(this.today);
            // With a budget, a ring of how today is going against what can
            // be spent today; tapping it opens the budget.
            final budget = BudgetStatus.of(
              group,
              today: this.today,
              firstDayOfWeek: firstDayOfWeekOf(context),
            );
            final locale = Localizations.localeOf(context);
            String money(double v) =>
                CurrencyDisplay.formatLocalizedText(v, group.currency, locale);
            final today = _Figure(
              label: gloc.today,
              value: spentToday,
              currency: group.currency,
              ring: switch (budget?.todayFraction) {
                final f? => BudgetRing(
                  fraction: f,
                  over: budget!.overToday,
                  size: 26,
                  strokeWidth: 3,
                ),
                null => null,
              },
              onTap: budget == null ? null : onOpenBudget,
              semanticLabel: switch (budget) {
                null => null,
                BudgetStatus(todayShare: final share?) when budget.overToday =>
                  gloc.budget_today_over(money(spentToday), money(share)),
                BudgetStatus(todayShare: final share?) =>
                  gloc.budget_today_within(money(spentToday), money(share)),
                _ => gloc.budget_today_open(money(spentToday)),
              },
            );
            // Side by side when "Today" has room for its amount at full
            // size; one under the other with large text, rather than
            // shrinking them. (The per-person figure is in Statistics.)
            final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
            final todayWidth = (constraints.maxWidth - 8) * 3 / 7;
            if (todayWidth >= _Figure.minSmallWidth * scale) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 4, child: total),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: today),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [total, const SizedBox(height: 8), today],
            );
          },
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  /// Width a small figure needs for a four-digit amount at full size.
  static const double minSmallWidth = 128;

  final String label;
  final double value;
  final String currency;
  final bool big;

  /// The budget ring after the amount, on its line ("Today" with a
  /// budget).
  final Widget? ring;
  final VoidCallback? onTap;

  /// Replaces label and amount for screen readers when tappable.
  final String? semanticLabel;

  const _Figure({
    required this.label,
    required this.value,
    required this.currency,
    this.big = false,
    this.ring,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(18);
    final figure = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Shrinks rather than truncates with large text.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(
              color: s.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // The ring sits on the amount's line, centred on it, so it reads
        // with the figure instead of floating between the two lines.
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: CurrencyDisplay(
                  value: value,
                  currency: currency,
                  valueFontSize: big ? 26 : 20,
                  currencyFontSize: big ? 14 : 12,
                  showDecimals: true,
                  alignment: MainAxisAlignment.start,
                ),
              ),
            ),
            if (ring case final ring?) ...[const SizedBox(width: 8), ring],
          ],
        ),
      ],
    );
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: figure,
    );
    return CardOutline(
      borderRadius: radius,
      child: Material(
        color: s.raisedSurface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : Semantics(
                button: true,
                label: semanticLabel,
                // excludeSemantics drops the InkWell's tap: carry it here,
                // or TalkBack reads the budget but can't open it.
                onTap: onTap,
                excludeSemantics: semanticLabel != null,
                child: InkWell(onTap: onTap, child: content),
              ),
      ),
    );
  }
}
