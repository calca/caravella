import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/expense_details.dart';
import '../../../data/expense_group.dart';
import '../../expense/expense_form_component.dart';

class ExpenseFormSheet extends StatelessWidget {
  final ExpenseGroup group;
  final ExpenseDetails? initialExpense;
  final void Function(ExpenseDetails) onExpenseSaved;
  final void Function(String) onCategoryAdded;
  final String title;
  final bool showDateAndNote;
  const ExpenseFormSheet({
    super.key,
    required this.group,
    this.initialExpense,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    required this.title,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
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
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
                      20,
                ),
                child: ExpenseFormComponent(
                  initialExpense: initialExpense,
                  participants: group.participants.map((p) => p.name).toList(),
                  categories: group.categories.map((c) => c.name).toList(),
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
