import 'package:material_ui/material_ui.dart';
import 'group_meta_line.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../home_constants.dart';

/// Displays the header section of a group card.
///
/// The group title and, under it, [GroupMetaLine]: the favorite's heart,
/// a shared group's sync circle, the type and the dates.
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

  /// The state and what the group is, on one quiet line ([GroupMetaLine]).
  Widget _buildDateRange(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: HomeLayoutConstants.smallSpacing,
    ),
    child: GroupMetaLine(
      group: group,
      foreground: _fg,
      showFavorite: showPinnedBadge,
    ),
  );
}
