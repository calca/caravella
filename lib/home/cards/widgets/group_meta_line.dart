import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/date_range_formatter.dart';
import 'package:material_ui/material_ui.dart';

import '../../../manager/group/group_type/group_type_localization.dart';
import '../../../sync/group_sync_badge.dart';
import '../../home_constants.dart';

/// The one quiet line under a group's title, the same on Home's card and on
/// the group page: the state first, then what the group is, read as one
/// phrase — "♥ ● ✈ Travel · 12 – 20 Nov" (· 4 people on the group page).
/// The heart only for the favorite, the sync circle only for a shared group
/// ([showShared]; the group page has its sync button instead); without dates
/// the line is just the type, with no gap left for them.
class GroupMetaLine extends StatelessWidget {
  final ExpenseGroup group;
  final Color foreground;

  /// The shared group's sync circle (Home); the group page shows the sync
  /// state on its round sync button instead.
  final bool showShared;

  /// "· 4 people" at the end (the group page).
  final bool showPeople;

  /// The heart of the favorite (off where the favorite is shown otherwise).
  final bool showFavorite;

  /// The type's name after its icon, and the dates: off on the Groups
  /// page's tiles, too narrow for them ("♥ ● ✈ 4 participants").
  final bool showTypeName;
  final bool showDates;

  /// The line's text size (smaller on the Groups page's tiles).
  final double fontSize;

  const GroupMetaLine({
    super.key,
    required this.group,
    required this.foreground,
    this.showShared = true,
    this.showPeople = false,
    this.showFavorite = true,
    this.showTypeName = true,
    this.showDates = true,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final type = group.groupType ?? ExpenseGroupType.other;
    final hasDates =
        showDates && (group.startDate != null || group.endDate != null);
    final typeName = GroupTypeLocalization.typeName(gloc, type);
    final text = [
      if (showTypeName) typeName,
      if (hasDates)
        formatDateRange(
          start: group.startDate,
          end: group.endDate,
          locale: Localizations.localeOf(context),
        ),
      if (showPeople) gloc.participant_count(group.participants.length),
    ].join(' · ');
    // Quiet by size, not by fading: the text color keeps its 4.5:1.
    final style = theme.textTheme.bodySmall?.copyWith(
      color: foreground,
      fontSize: fontSize,
    );
    final large = HomeLayoutConstants.isLargeText(context);
    return Row(
      crossAxisAlignment: large
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (showFavorite && group.pinned) ...[
          Icon(
            Icons.favorite_rounded,
            size: 14,
            color: foreground,
            semanticLabel: gloc.pin,
          ),
          const SizedBox(width: 6),
        ],
        if (showShared && group.syncEnabled) ...[
          GroupSyncBadge(
            group: group,
            dotOnly: true,
            background: Colors.transparent,
            foreground: foreground,
          ),
          const SizedBox(width: 6),
        ],
        // Its name is in the text; without it the icon says it.
        Icon(
          type.icon,
          size: 14,
          color: foreground,
          semanticLabel: showTypeName ? null : typeName,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: style,
            // Large text: two lines before the ellipsis.
            maxLines: large ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
