import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import 'group_header.dart';
import 'group_total.dart';
import 'group_actions.dart';

/// Header section for expense group detail page with group info and actions
class ExpenseGroupHeaderSection extends StatelessWidget {
  final ExpenseGroup trip;
  final bool hideHeader;
  final double totalExpenses;
  final VoidCallback? onOverview;
  final VoidCallback onOptions;
  
  const ExpenseGroupHeaderSection({
    super.key,
    required this.trip,
    required this.hideHeader,
    required this.totalExpenses,
    this.onOverview,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SliverToBoxAdapter(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: child,
            ),
          ),
          child: hideHeader
              ? const SizedBox.shrink(key: ValueKey('header-hidden'))
              : Container(
                  key: const ValueKey('header-visible'),
                  width: double.infinity,
                  color: colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GroupHeader(trip: trip),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GroupTotal(
                                total: totalExpenses,
                                currency: trip.currency,
                              ),
                            ),
                            GroupActions(
                              hasExpenses: trip.expenses.isNotEmpty,
                              onOverview: trip.expenses.isNotEmpty ? onOverview : null,
                              onOptions: onOptions,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}