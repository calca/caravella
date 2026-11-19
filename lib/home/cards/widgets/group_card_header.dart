import 'package:material_ui/material_ui.dart';
import '../../../sync/group_sync_badge.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../home_constants.dart';
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/date_range_formatter.dart';

/// Displays the header section of a group card.
///
/// This includes the group title and optionally the pin badge, date range,
/// and sync status indicator for shared groups.
class GroupCardHeader extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final bool showDateRange;
  final bool showPinnedBadge;
  final bool centerTitleHorizontally;

  /// Whether the group's data is fully synced with peers.
  /// `null` means sync status is unknown or not applicable.
  final bool? isSynced;

  /// Text color; the theme's `onSurface` by default.
  final Color? foreground;

  const GroupCardHeader({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    this.isSynced,
    this.showDateRange = true,
    this.showPinnedBadge = true,
    this.centerTitleHorizontally = false,
    this.foreground,
  });

  Color get _fg => foreground ?? theme.colorScheme.onSurface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerTitleHorizontally
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        if (showDateRange) _buildDateRange(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final title = Text(
      group.title,
      // Large text: two lines before the ellipsis.
      maxLines: HomeLayoutConstants.isLargeText(context) ? 2 : 1,
      textAlign: centerTitleHorizontally ? TextAlign.center : TextAlign.start,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: HomeLayoutConstants.cardTitleFontSize,
        color: _fg,
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (centerTitleHorizontally) {
      return SizedBox(width: double.infinity, child: title);
    }

    return title;
  }

  Widget _buildDateRange(BuildContext context) {
    final favorite = group.pinned && showPinnedBadge;
    final hasDates = group.startDate != null || group.endDate != null;
    if (!hasDates && !favorite && !group.syncEnabled) {
      return const SizedBox(height: HomeLayoutConstants.smallSpacing);
    }

    final pillBackground = _fg.withValues(
      alpha: foreground == null ? 0.05 : 0.18,
    );
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: _fg,
      fontWeight: FontWeight.w600,
    );
    final dateText = formatDateRange(
      start: group.startDate,
      end: group.endDate,
      locale: Localizations.localeOf(context),
    );
    final dateStyle = theme.textTheme.bodySmall?.copyWith(color: _fg);
    final dates = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event_outlined, size: 14, color: _fg),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            dateText,
            style: dateStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    Widget favoritePill({required bool withLabel}) => Semantics(
      label: localizations.pin,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: pillBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, size: 12, color: _fg),
            if (withLabel) ...[
              const SizedBox(width: 4),
              Text(localizations.pin, style: labelStyle),
            ],
          ],
        ),
      ),
    );
    final shared = group.syncEnabled
        ? GroupSyncBadge(
            group: group,
            background: pillBackground,
            foreground: _fg,
          )
        : null;

    // Large text: the pills may go under the dates rather than cut them.
    if (HomeLayoutConstants.isLargeText(context)) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: HomeLayoutConstants.smallSpacing,
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            if (hasDates) dates,
            if (favorite) favoritePill(withLabel: true),
            ?shared,
          ],
        ),
      );
    }

    // One line: the dates at the start, the pills at the end (or at the
    // start, without dates). When it's
    // tight the favorite pill keeps only its heart, and the dates are cut
    // last.
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: HomeLayoutConstants.smallSpacing,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaler = MediaQuery.textScalerOf(context);
          double textWidth(String text, TextStyle? style) => (TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: scaler,
            maxLines: 1,
          )..layout()).width;
          // Pill: 8 + content + 8; the shared one has a dot (8 + 6).
          final needed =
              (hasDates ? 18 + textWidth(dateText, dateStyle) + 8 : 0) +
              (favorite
                  ? 16 + 12 + 4 + textWidth(localizations.pin, labelStyle) + 8
                  : 0) +
              (group.syncEnabled
                  ? 16 +
                        14 +
                        textWidth(
                          gen.AppLocalizations.of(context).sync_group_shared,
                          labelStyle,
                        )
                  : 0);
          final roomy = needed <= constraints.maxWidth;
          final pills = [if (favorite) favoritePill(withLabel: roomy), ?shared];
          return Row(
            children: [
              if (hasDates)
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: dates,
                  ),
                ),
              // Without dates the pills start the line, under the title.
              for (final (i, pill) in pills.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                pill,
              ],
            ],
          );
        },
      ),
    );
  }
}
