import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/widgets/expense_amount_card.dart';
import '../../../manager/details/pages/expense_group_detail_page.dart';

class GroupCardRecents extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const GroupCardRecents({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.recent_expenses.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        FutureBuilder<List<ExpenseDetails>>(
          future: ExpenseGroupStorageV2.getRecentExpenses(group.id, limit: 2),
          builder: (ctx, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            
            // Handle error state silently (fail gracefully)
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }
            
            final lastTwo = snapshot.data!;
            if (lastTwo.isEmpty) return const SizedBox.shrink();
            
            return Column(
              children: lastTwo.map((e) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  child: ExpenseAmountCard(
                    title: e.name ?? '',
                    coins: (e.amount ?? 0).toInt(),
                    checked: true,
                    paidBy: e.paidBy,
                    category: e.category.name,
                    date: e.date,
                    showDate: false,
                    compact: true,
                    fullWidth: true,
                    currency: group.currency,
                    onTap: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => ExpenseGroupDetailPage(trip: group),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
