import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_total.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Small widget extracted from GroupCardContent showing
/// total and today's spending side-by-side.
class GroupCardAmounts extends StatelessWidget {
  final ExpenseGroup group;
  final ThemeData theme;
  final gen.AppLocalizations localizations;

  const GroupCardAmounts({
    super.key,
    required this.group,
    required this.theme,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpenses = group.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );
    final now = DateTime.now();
    final todaySpending = group.expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold<double>(0, (s, e) => s + (e.amount ?? 0));

    final primary = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: GroupTotal(total: totalExpenses, currency: group.currency),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CurrencyDisplay(
                  value: todaySpending.abs(),
                  currency: group.currency,
                  valueFontSize: 16,
                  currencyFontSize: 12,
                  alignment: MainAxisAlignment.start,
                  showDecimals: true,
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.spent_today.toLowerCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
