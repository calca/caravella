import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../home_constants.dart';
import '../../../manager/details/widgets/group_header.dart'
    show ExpenseGroupAvatar;

/// Displays the header section of a group card.
///
/// This includes the group title and optionally the pin badge and date range.
class GroupCardHeader extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const GroupCardHeader({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildTitle(), _buildDateRange()],
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ExpenseGroupAvatar(
        //   trip: group,
        //   size: HomeLayoutConstants.headerHeight - 32,
        //   backgroundColor:
        //       theme.colorScheme.surfaceContainer, // avatar diameter ~56
        // ),
        // const SizedBox(width: 8),
        Expanded(
          child: Text(
            group.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: HomeLayoutConstants.cardTitleFontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRange() {
    // Show pin badge even if there are no dates
    if (group.startDate == null && group.endDate == null && !group.pinned) {
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
            if (group.pinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.05,
                  ),
                  borderRadius: BorderRadius.circular(
                    HomeLayoutConstants.buttonBorderRadius,
                  ),
                ),
                child: Text(
                  localizations.pin,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: HomeLayoutConstants.smallSpacing),
      ],
    );
  }
}
