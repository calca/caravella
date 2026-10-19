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

/// Card opening the map of the group's expenses, shown in its statistics
/// when some expense has a location.
class GroupMapCard extends StatelessWidget {
  final ExpenseGroup group;

  const GroupMapCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final places = groupPlacesCount(group);
    final radius = BorderRadius.circular(20);
    void open() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseLocationsMapPage(group: group)),
    );

    return Semantics(
      button: true,
      label: '${gloc.quick_action_map}, ${gloc.places_count(places)}',
      onTap: open,
      excludeSemantics: true,
      child: CardOutline(
        borderRadius: radius,
        child: Material(
          color: s.raisedSurface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: open,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.primaryContainer,
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      color: s.onPrimaryContainer,
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
                          gloc.places_count(places),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: s.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
