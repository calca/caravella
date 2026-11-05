import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../../details/pages/expense_group_detail_page.dart';
import '../../details/pages/tabs/usecase/date_range_formatter.dart';
import 'group_options.dart';

/// Card of the Groups page: a grid tile, or the wide card used for the
/// favorite group at the top. What it shows is a [GroupCardFace].
///
/// Tap opens the group; long press opens [showGroupOptionsSheet].
class GroupPhotoCard extends StatelessWidget {
  final ExpenseGroup group;
  final bool wide;
  final Future<void> Function(String groupId, bool archived) onArchiveToggle;
  final VoidCallback? onChanged;

  const GroupPhotoCard({
    super.key,
    required this.group,
    required this.onArchiveToggle,
    this.onChanged,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final radius = GroupCardFace.borderRadiusFor(wide: wide);

    final Color? color = group.color == null
        ? null
        : ExpenseGroupColorPalette.isLegacyColorValue(group.color)
        ? Color(group.color!)
        : ExpenseGroupColorPalette.resolveColor(group.color, s);

    final people = gloc.participant_count(group.participants.length);
    final dates = (group.startDate != null || group.endDate != null)
        ? formatDateRange(
            start: group.startDate,
            end: group.endDate,
            locale: Localizations.localeOf(context),
          )
        : null;
    final total = group.getTotalExpenses();

    void open() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseGroupDetailPage(trip: group)),
    );
    void options() => showGroupOptionsSheet(
      context,
      trip: group,
      onArchiveToggle: onArchiveToggle,
      onDelete: onChanged,
      onPin: onChanged,
    );

    return CardOutline(
      borderRadius: radius,
      child: Semantics(
        button: true,
        label: [
          group.title,
          if (group.pinned) gloc.pin,
          ?dates,
          people,
          CurrencyDisplay.formatLocalizedText(
            total,
            group.currency,
            Localizations.maybeLocaleOf(context),
          ),
        ].join(', '),
        onTap: open,
        onLongPress: options,
        excludeSemantics: true,
        child: Material(
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: open,
            onLongPress: options,
            child: GroupCardFace(
              title: group.title,
              subtitle: !wide || dates == null ? people : '$dates · $people',
              total: total,
              currency: group.currency,
              photoPath: group.file,
              color: color,
              icon: (group.groupType ?? ExpenseGroupType.other).icon,
              wide: wide,
              favoriteLabel: wide ? gloc.pin : null,
            ),
          ),
        ),
      ),
    );
  }
}
