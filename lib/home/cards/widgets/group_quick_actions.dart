import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../../../manager/details/pages/expense_group_detail_page.dart';
import '../../../manager/details/pages/expense_locations_map_page.dart';
import '../../../manager/details/pages/expense_search_page.dart';
import '../../../manager/details/pages/unified_overview_page.dart';
import '../../../manager/details/widgets/expense_export_actions.dart';

/// Row of shortcuts under the featured group card on Home: overview, map,
/// search and share/export for that group. They sit below the floating
/// navigation and are reached by scrolling (#529). Disabled while the group
/// has no expenses, like the matching actions on the group page.
class GroupQuickActions extends StatelessWidget {
  final ExpenseGroup group;

  const GroupQuickActions({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final hasExpenses = group.expenses.isNotEmpty;
    final hasPlaces = group.expenses.any((e) => e.location != null);

    void push(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickAction(
          icon: Icons.bar_chart_rounded,
          label: gloc.overview,
          onTap: hasExpenses
              ? () => push(UnifiedOverviewPage(trip: group))
              : null,
        ),
        _QuickAction(
          icon: Icons.map_outlined,
          label: gloc.quick_action_map,
          onTap: hasPlaces
              ? () => push(ExpenseLocationsMapPage(group: group))
              : null,
        ),
        _QuickAction(
          icon: Icons.search_rounded,
          label: gloc.quick_action_search,
          onTap: hasExpenses
              ? () => ExpenseSearchPage.show(
                  context,
                  expenses: group.expenses,
                  categories: group.categories,
                  participants: group.participants,
                  currency: group.currency,
                  groupName: group.title,
                  // Expenses are edited from the group page.
                  onExpenseTap: (_) =>
                      push(ExpenseGroupDetailPage(trip: group)),
                )
              : null,
        ),
        _QuickAction(
          icon: Icons.ios_share_rounded,
          label: gloc.share_label,
          onTap: hasExpenses
              ? () => showExpenseExportOptionsSheet(context, group)
              : null,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final enabled = onTap != null;
    final fg = enabled ? s.onSurface : s.onSurface.withValues(alpha: 0.38);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.raisedSurface,
                ),
                child: Icon(icon, color: fg),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
