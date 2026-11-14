import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../pages/expense_locations_map_page.dart';

/// Number of distinct places among the group's expenses (coordinates
/// rounded to ~100 m), 0 when none has a location.
int groupPlacesCount(ExpenseGroup group) => {
  for (final e in group.expenses)
    if (e.location?.latitude != null && e.location?.longitude != null)
      '${e.location!.latitude!.toStringAsFixed(3)},'
          '${e.location!.longitude!.toStringAsFixed(3)}',
}.length;

/// Map card of the group's statistics. With places it opens the map of the
/// group's expenses. Without any, it explains why: when the group's
/// automatic location is off, tapping it opens the setting
/// ([onEnableLocation]); otherwise it is just a note, not tappable.
class GroupMapCard extends StatelessWidget {
  final ExpenseGroup group;

  /// Opens the group setting that turns automatic location on.
  final VoidCallback? onEnableLocation;

  const GroupMapCard({super.key, required this.group, this.onEnableLocation});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final places = groupPlacesCount(group);
    final VoidCallback? onTap = places > 0
        ? () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpenseLocationsMapPage(group: group),
            ),
          )
        : group.autoLocationEnabled
        ? null
        : onEnableLocation;
    final subtitle = places > 0
        ? gloc.places_count(places)
        : group.autoLocationEnabled
        ? gloc.map_no_places
        : gloc.map_location_off;

    return LinkCard(
      icon: places > 0 || group.autoLocationEnabled
          ? Icons.map_outlined
          : Icons.location_off_outlined,
      title: gloc.quick_action_map,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
