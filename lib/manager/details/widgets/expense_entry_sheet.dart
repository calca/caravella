import 'package:flutter/material.dart';
import '../../../data/expense_details.dart';
import '../../../data/expense_group.dart';
import '../../expense/expense_form_component.dart';

/// Unified sheet for creating or editing an expense.
/// If [initialExpense] is provided we are editing, otherwise creating a new one.
class ExpenseEntrySheet extends StatelessWidget {
  final ExpenseGroup group;
  final ExpenseDetails? initialExpense;
  final void Function(ExpenseDetails) onExpenseSaved; // add or update
  final void Function(String) onCategoryAdded;
  final VoidCallback? onDelete; // only used in edit mode
  final bool fullEdit;

  const ExpenseEntrySheet({
    super.key,
    required this.group,
    this.initialExpense,
    required this.onExpenseSaved,
    required this.onCategoryAdded,
    this.onDelete,
    this.fullEdit = true,
  });

  bool get _isEdit => initialExpense != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isEdit && onDelete != null)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      backgroundColor: colorScheme.surfaceContainer,
                    ),
                    tooltip: 'Delete', // TODO localize
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_outlined,
                      color: colorScheme.error,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bottomInset = MediaQuery.of(context).padding.bottom;
                  final keyboard = MediaQuery.of(context).viewInsets.bottom;
                  const extra = 24.0;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20 + bottomInset + extra + keyboard,
                    ),
                    child: ExpenseFormComponent(
                      initialExpense: initialExpense,
                      participants: group.participants,
                      categories: group.categories,
                      tripStartDate: group.startDate,
                      tripEndDate: group.endDate,
                      shouldAutoClose: false,
                      fullEdit: fullEdit,
                      groupTitle: group.title,
                      currency: group.currency,
                      onExpenseAdded: onExpenseSaved,
                      onCategoryAdded: onCategoryAdded,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
