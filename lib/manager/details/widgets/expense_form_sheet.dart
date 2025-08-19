import 'package:flutter/material.dart';
import '../../../data/expense_details.dart';
import '../../../data/expense_group.dart';
import '../../expense/expense_form_component.dart';

class ExpenseFormSheet extends StatelessWidget {
  final ExpenseGroup group;
  final ExpenseDetails? initialExpense;
  final void Function(ExpenseDetails) onExpenseSaved;
  final void Function(String) onCategoryAdded;
  final bool showDateAndNote;
  const ExpenseFormSheet({
    super.key,
    required this.group,
    this.initialExpense,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.showDateAndNote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar with only a close button (title removed per UX request)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
                      20,
                ),
                child: ExpenseFormComponent(
                  initialExpense: initialExpense,
                  participants: group.participants,
                  categories: group.categories,
                  tripStartDate: group.startDate,
                  tripEndDate: group.endDate,
                  shouldAutoClose: false,
                  showDateAndNote: showDateAndNote,
                  onExpenseAdded: onExpenseSaved,
                  onCategoryAdded: onCategoryAdded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
