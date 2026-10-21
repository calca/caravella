import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../../sync/group_sync_badge.dart';
import '../pages/tabs/usecase/date_range_formatter.dart';

/// The group's photo or color behind the top of its page, melting into
/// [pageColor] at the bottom. A photo (as on the Home and Groups cards) is in
/// full color at the top and melts into the page color, where dates, title
/// and figure cards keep the theme's colors.
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

  /// Extra room above the title with a photo, so the photo shows.
  static const double photoExtraTop = 96;

  /// Text color for the band's upper part (title, top bar).
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
        solidExtent: 160,
        fadeExtent: 160,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: color!),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                pageColor.withValues(alpha: 0),
                pageColor.withValues(alpha: 0),
                pageColor,
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
      ],
    );
  }
}

/// Title block of the group page: dates · people, the group name, and the
/// key figures (total, today, per person) in small cards.
class GroupDetailHeader extends StatelessWidget {
  final ExpenseGroup group;
  final Color foreground;

  const GroupDetailHeader({
    super.key,
    required this.group,
    required this.foreground,
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
    final perPerson = group.participants.isEmpty
        ? 0.0
        : group.getTotalExpenses() / group.participants.length;

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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: _Figure(
                  label: gloc.group_total,
                  value: group.getTotalExpenses(),
                  currency: group.currency,
                  big: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _Figure(
                  label: gloc.today,
                  value: group.getTodaySpendingSync(),
                  currency: group.currency,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _Figure(
                  label: gloc.per_person,
                  value: perPerson,
                  currency: group.currency,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final double value;
  final String currency;
  final bool big;

  const _Figure({
    required this.label,
    required this.value,
    required this.currency,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(18);
    return CardOutline(
      borderRadius: radius,
      child: Material(
        color: s.raisedSurface,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: s.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
