import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../home_constants.dart';

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

  const GroupCardHeader({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    this.isSynced,
    this.showDateRange = true,
    this.showPinnedBadge = true,
    this.centerTitleHorizontally = false,
  });

  String _formatDateRange(ExpenseGroup group, gen.AppLocalizations loc) {
    final start = group.startDate;
    final end = group.endDate;

    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Dal ${_formatDate(start)}';
    } else if (end != null) {
      return 'Fino al ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final currentYear = DateTime.now().year;
    if (date.year == currentYear) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerTitleHorizontally
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [_buildTitle(), if (showDateRange) _buildDateRange()],
    );
  }

  Widget _buildTitle() {
    final title = Text(
      group.title,
      textAlign: centerTitleHorizontally ? TextAlign.center : TextAlign.start,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: HomeLayoutConstants.cardTitleFontSize,
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
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          HomeLayoutConstants.buttonBorderRadius,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateRange() {
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
              Icon(
                Icons.event_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatDateRange(group, localizations),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (group.pinned && showPinnedBadge) _buildPill(localizations.pin),
            if (group.pinned && showPinnedBadge && group.syncEnabled)
              const SizedBox(width: 4),
            if (group.syncEnabled) _buildPill(localizations.sync_group_shared),
          ],
        ),
        const SizedBox(height: HomeLayoutConstants.smallSpacing),
      ],
    );
  }
}
