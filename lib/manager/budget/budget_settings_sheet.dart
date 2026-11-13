import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// What [showBudgetSettingsSheet] gives back.
sealed class BudgetSheetResult {
  const BudgetSheetResult();
}

/// Saved with this budget.
class BudgetSaved extends BudgetSheetResult {
  final GroupBudget budget;
  const BudgetSaved(this.budget);
}

/// "Remove budget".
class BudgetRemoved extends BudgetSheetResult {
  const BudgetRemoved();
}

/// The period a new budget starts on: the whole trip, a month for a home
/// or a family, a month for the rest.
BudgetPeriod suggestedBudgetPeriod(ExpenseGroupType? type) => switch (type) {
  ExpenseGroupType.travel => BudgetPeriod.total,
  _ => BudgetPeriod.monthly,
};

/// The sheet setting a group's budget: its period (in total, per month,
/// week or day) and amount, in the group's [currency]. Null when closed
/// without saving.
Future<BudgetSheetResult?> showBudgetSettingsSheet(
  BuildContext context, {
  required GroupBudget? budget,
  required String currency,
  ExpenseGroupType? groupType,
}) {
  return showAppBottomSheet<BudgetSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BudgetSettingsSheet(
      budget: budget,
      currency: currency,
      groupType: groupType,
    ),
  );
}

class BudgetSettingsSheet extends StatefulWidget {
  final GroupBudget? budget;
  final String currency;
  final ExpenseGroupType? groupType;

  const BudgetSettingsSheet({
    super.key,
    required this.budget,
    required this.currency,
    this.groupType,
  });

  @override
  State<BudgetSettingsSheet> createState() => _BudgetSettingsSheetState();
}

class _BudgetSettingsSheetState extends State<BudgetSettingsSheet> {
  late BudgetPeriod _period =
      widget.budget?.period ?? suggestedBudgetPeriod(widget.groupType);
  late final TextEditingController _amount = TextEditingController(
    text: switch (widget.budget?.amount) {
      final a? when a == a.roundToDouble() => a.toStringAsFixed(0),
      final a? => a.toStringAsFixed(2),
      null => '',
    },
  );

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  double? get _value {
    final v = AmountField.parse(_amount.text);
    return v != null && v > 0 ? v : null;
  }

  void _save() {
    final value = _value;
    if (value == null) return;
    Navigator.of(
      context,
    ).pop(BudgetSaved(GroupBudget(amount: value, period: _period)));
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final periods = BudgetPeriod.values;
    final amountLabel = switch (_period) {
      BudgetPeriod.total => gloc.budget_amount_total,
      BudgetPeriod.monthly => gloc.budget_amount_monthly,
      BudgetPeriod.weekly => gloc.budget_amount_weekly,
      BudgetPeriod.daily => gloc.budget_amount_daily,
    };
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CaravellaBottomSheetScaffold(
        title: gloc.budget,
        subtitle: gloc.budget_sheet_description,
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: PillSegmentedControl(
                labels: [for (final p in periods) budgetPeriodName(gloc, p)],
                selectedIndex: periods.indexOf(_period),
                onChanged: (i) => setState(() => _period = periods[i]),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              amountLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            AmountField(
              controller: _amount,
              currency: widget.currency,
              label: amountLabel,
              textInputAction: TextInputAction.done,
              onSubmitted: _save,
            ),
            const SizedBox(height: 4),
            Text(
              gloc.budget_currency_hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (widget.budget != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(const BudgetRemoved()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(gloc.budget_remove),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _value == null ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text(gloc.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "In total", "Monthly", "Weekly" or "Daily".
String budgetPeriodName(gen.AppLocalizations gloc, BudgetPeriod period) =>
    switch (period) {
      BudgetPeriod.total => gloc.budget_period_total,
      BudgetPeriod.monthly => gloc.budget_period_monthly,
      BudgetPeriod.weekly => gloc.budget_period_weekly,
      BudgetPeriod.daily => gloc.budget_period_daily,
    };
