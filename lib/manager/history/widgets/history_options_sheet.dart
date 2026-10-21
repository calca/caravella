import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../../details/pages/tabs/usecase/date_range_formatter.dart';

/// A group's options: favorite and archive in one card, delete in its own
/// red card below.
class HistoryOptionsSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback onPinToggle;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  const HistoryOptionsSheet({
    super.key,
    required this.trip,
    required this.onPinToggle,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final people = gloc.participant_count(trip.participants.length);
    final dates = trip.startDate != null || trip.endDate != null
        ? formatDateRange(
            start: trip.startDate,
            end: trip.endDate,
            locale: Localizations.localeOf(context),
          )
        : null;

    return CaravellaBottomSheetScaffold(
      title: trip.title,
      subtitle: dates == null ? people : '$dates · $people',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsGroup(
            topSpacing: 0,
            children: [
              // An archived group can't be the favorite.
              if (!trip.archived)
                SettingsTile(
                  icon: trip.pinned
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  title: trip.pinned ? gloc.unpin_group : gloc.pin_group,
                  chevron: false,
                  onTap: onPinToggle,
                ),
              SettingsTile(
                icon: trip.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                title: trip.archived ? gloc.unarchive : gloc.archive,
                chevron: false,
                onTap: onArchiveToggle,
              ),
            ],
          ),
          SettingsGroup(
            topSpacing: 12,
            children: [
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: gloc.delete,
                destructive: true,
                chevron: false,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
