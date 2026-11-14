import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../budget/budget_detail_sheet.dart';

/// Budget card of the group's statistics, like the map card: "Budget" and,
/// under it, the budget and a calm word on how it's going ("600 € a month ·
/// on track", or "a bit above plan"); no figures, bars or colors, so it
/// informs without alarming. Without a budget: "Not set". Tapping it opens
/// the budget sheet ([onOpen]), or its settings when there is none.
class GroupBudgetCard extends StatelessWidget {
  final ExpenseGroup group;
  final VoidCallback? onOpen;

  /// "Today" for the status; now when null (tests set it).
  final DateTime? today;

  const GroupBudgetCard({
    super.key,
    required this.group,
    this.onOpen,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final status = BudgetStatus.of(
      group,
      today: today,
      firstDayOfWeek: firstDayOfWeekOf(context),
    );
    final subtitle = switch (status) {
      null => gloc.budget_not_set,
      final s => [
        switch (s.budget.period) {
          BudgetPeriod.total => gloc.budget_rate_total,
          BudgetPeriod.monthly => gloc.budget_rate_monthly,
          BudgetPeriod.weekly => gloc.budget_rate_weekly,
          BudgetPeriod.daily => gloc.budget_rate_daily,
        }(
          CurrencyDisplay.formatLocalizedText(
            s.budget.amount,
            group.currency,
            locale,
          ),
        ),
        s.onTrack ? gloc.budget_on_track : gloc.budget_above_plan,
      ].join(' · '),
    };
    return LinkCard(
      icon: Icons.savings_outlined,
      title: gloc.budget,
      subtitle: subtitle,
      onTap: onOpen,
    );
  }
}
