import 'package:flutter/material.dart';
import '../../../data/expense_details.dart';
import '../../../data/expense_group.dart';
import '../../expense/expense_form_component.dart';

class EditExpenseSheet extends StatelessWidget {
  final ExpenseGroup group;
  final ExpenseDetails expense;
// Removed unused imports
  final void Function(ExpenseDetails) onExpenseAdded;
  final void Function(String) onCategoryAdded;
  final void Function() onDelete;
  final String title;
  const EditExpenseSheet({
    super.key,
    required this.group,
    required this.expense,
    required this.onExpenseAdded,
    required this.onCategoryAdded,
    required this.onDelete,
    required this.title,
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
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
                  initialExpense: expense,
                  participants: group.participants.map((p) => p.name).toList(),
                  categories: group.categories,
                  tripStartDate: group.startDate,
                  tripEndDate: group.endDate,
                  shouldAutoClose: false,
                  onExpenseAdded: onExpenseAdded,
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
