import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import '../../../data/model/expense_details.dart';
import '../../../data/model/expense_category.dart';
import '../../../data/model/expense_participant.dart';
import 'filtered_expense_list.dart';

/// Content section for expense group detail page with expense list
class ExpenseGroupContentSection extends StatelessWidget {
  final ExpenseGroup trip;
  final Function(ExpenseDetails) onExpenseTap;
  final Function(bool) onFiltersVisibilityChanged;
  final VoidCallback onAddExpense;
  final double bottomPadding;
  
  const ExpenseGroupContentSection({
    super.key,
    required this.trip,
    required this.onExpenseTap,
    required this.onFiltersVisibilityChanged,
    required this.onAddExpense,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContentSlivers(context);
  }
  
  List<Widget> buildSlivers(BuildContext context) {
    return _buildContentSlivers(context);
  }
  
  List<Widget> _buildContentSlivers(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return [
      SliverToBoxAdapter(
        child: Container(
          color: colorScheme.surfaceContainer, // background behind the decorated box
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilteredExpenseList(
                    expenses: trip.expenses,
                    currency: trip.currency,
                    onExpenseTap: onExpenseTap,
                    categories: trip.categories,
                    participants: trip.participants,
                    onFiltersVisibilityChanged: onFiltersVisibilityChanged,
                    onAddExpense: onAddExpense,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.only(bottom: 0),
        sliver: SliverToBoxAdapter(
          child: Container(
            height: bottomPadding,
            color: colorScheme.surface,
          ),
        ),
      ),
    ];
  }
}