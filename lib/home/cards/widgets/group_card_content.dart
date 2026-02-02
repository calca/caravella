import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'group_card_header.dart';
import 'group_card_amounts.dart';
// group_card_stats.dart removed import (not needed here)
import 'add_expense_controller.dart';
import 'group_card_recents.dart';

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
                const Spacer(),
                GroupCardAmounts(
                  group: currentGroup,
                  theme: theme,
                  localizations: localizations,
                ),
                const Spacer(),
                GroupCardRecents(
                  group: currentGroup,
                  localizations: localizations,
                  theme: theme,
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
