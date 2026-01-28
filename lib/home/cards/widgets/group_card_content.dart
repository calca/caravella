import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../home_constants.dart';
import 'group_card_header.dart';
import 'group_card_amounts.dart';
// group_card_stats.dart removed import (not needed here)
import 'add_expense_controller.dart';
import '../../../manager/details/widgets/expense_amount_card.dart';
import '../../../manager/details/pages/expense_group_detail_page.dart';

/// Main content widget for expense group cards.
///
/// This is a composition of smaller, focused widgets:
/// - [GroupCardHeader] - Title and date range
/// - [GroupCardTotalAmount] - Total expenses display
/// - [GroupCardStats] - Charts and statistics
/// - [GroupCardAddButton] - Add expense button
class GroupCardContent extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseGroupNotifier>(
      builder: (context, groupNotifier, child) {
        // If this group was updated, use data from the notifier
        final currentGroup = (groupNotifier.currentGroup?.id == group.id)
            ? groupNotifier.currentGroup!
            : group;

        final addExpenseController = AddExpenseController(
          group: currentGroup,
          onExpenseAdded: onExpenseAdded,
          onCategoryAdded: onCategoryAdded,
        );

        return LayoutBuilder(
          builder: (ctx2, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupCardHeader(
                  group: currentGroup,
                  localizations: localizations,
                  theme: theme,
                ),
                GroupCardAmounts(
                  group: currentGroup,
                  theme: theme,
                  localizations: localizations,
                ),
                // Show last 2 expenses using the same card widget as the details page
                const SizedBox(height: HomeLayoutConstants.smallSpacing),
                Spacer(),
                Text(
                  localizations.recent_expenses,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Builder(
                  builder: (ctx) {
                    final expenses = List<ExpenseDetails>.from(
                      currentGroup.expenses,
                    );
                    expenses.sort((a, b) => b.date.compareTo(a.date));
                    final lastTwo = expenses.take(2).toList();
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
                            currency: currentGroup.currency,
                            onTap: () {
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => ExpenseGroupDetailPage(
                                    trip: currentGroup,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                GroupCardAddButton(
                  group: currentGroup,
                  theme: theme,
                  controller: addExpenseController,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
