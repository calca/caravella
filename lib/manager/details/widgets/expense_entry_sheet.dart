import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import '../../expense/expense_form_component.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// Unified sheet for creating or editing an expense.
/// If [initialExpense] is provided we are editing, otherwise creating a new one.
class ExpenseEntrySheet extends StatefulWidget {
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

  @override
  State<ExpenseEntrySheet> createState() => _ExpenseEntrySheetState();
}

class _ExpenseEntrySheetState extends State<ExpenseEntrySheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    // Avoid double bottom padding: we override scaffold padding bottom to 0 and manage internally.
    const baseExtra = 8.0; // uniform bottom extra spacing for all modes
    final internalBottom = bottomInset + baseExtra + keyboard;
    return GroupBottomSheetScaffold(
      scrollable: true,
      scrollController: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Padding(
        padding: EdgeInsets.only(bottom: internalBottom),
        child: ExpenseFormComponent(
          initialExpense: widget.initialExpense,
          participants: widget.group.participants,
          categories: widget.group.categories,
          tripStartDate: widget.group.startDate,
          tripEndDate: widget.group.endDate,
          shouldAutoClose: false,
          fullEdit: widget.fullEdit,
          groupTitle: widget.group.title,
          currency: widget.group.currency,
          onExpenseAdded: widget.onExpenseSaved,
          onCategoryAdded: widget.onCategoryAdded,
          onDelete: widget.onDelete,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}
