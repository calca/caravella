import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_total.dart';
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

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: GroupTotal(total: totalExpenses, currency: group.currency),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GroupTotal(
                total: todaySpending,
                currency: group.currency,
                title: localizations.spent_today,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
