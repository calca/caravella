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
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final places = groupPlacesCount(group);
    final radius = BorderRadius.circular(20);
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

    return Semantics(
      button: onTap != null,
      label: '${gloc.quick_action_map}, $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: CardOutline(
        borderRadius: radius,
        child: Material(
          color: s.raisedSurface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.surfaceContainerHighest,
                    ),
                    child: Icon(
                      places > 0 || group.autoLocationEnabled
                          ? Icons.map_outlined
                          : Icons.location_off_outlined,
                      color: s.onSurface,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gloc.quick_action_map,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: s.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
