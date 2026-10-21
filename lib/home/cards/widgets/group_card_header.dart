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
      children: [_buildTitle(), if (showDateRange) _buildDateRange(context)],
    );
  }

  Widget _buildTitle() {
    final title = Text(
      group.title,
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

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _fg.withValues(alpha: foreground == null ? 0.05 : 0.18),
        borderRadius: BorderRadius.circular(
          HomeLayoutConstants.buttonBorderRadius,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateRange(BuildContext context) {
    // Show pin/shared badges even if there are no dates
    if (group.startDate == null &&
        group.endDate == null &&
        !group.pinned &&
        !group.syncEnabled) {
      return const SizedBox(height: HomeLayoutConstants.smallSpacing);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: HomeLayoutConstants.smallSpacing),
        Row(
          children: [
            if (group.startDate != null || group.endDate != null) ...[
              Icon(Icons.event_outlined, size: 14, color: _fg),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formatDateRange(
                    start: group.startDate,
                    end: group.endDate,
                    locale: Localizations.localeOf(context),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: _fg),
                ),
              ),
            ] else
              const Spacer(),
            if (group.pinned && showPinnedBadge) _buildPill(localizations.pin),
            if (group.pinned && showPinnedBadge && group.syncEnabled)
              const SizedBox(width: 4),
            if (group.syncEnabled)
              GroupSyncBadge(
                group: group,
                background: _fg.withValues(
                  alpha: foreground == null ? 0.05 : 0.18,
                ),
                foreground: _fg,
              ),
          ],
        ),
        const SizedBox(height: HomeLayoutConstants.smallSpacing),
      ],
    );
  }
}
