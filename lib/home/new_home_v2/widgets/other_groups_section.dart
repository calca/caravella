import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';

/// Section displaying other active groups in horizontal scrollable cards.
class OtherGroupsSection extends StatelessWidget {
  final List<ExpenseGroup> groups;
  final Function(ExpenseGroup)? onGroupTap;

  const OtherGroupsSection({
    super.key,
    required this.groups,
    this.onGroupTap,
  });

  double _calculateBalance(ExpenseGroup group) {
    // Simplified balance calculation
    double balance = 0.0;
    final userName = 'Tu';
    
    for (final expense in group.expenses) {
      if (expense.paidBy.name == userName) {
        balance += expense.amount;
      }
      final participantCount = expense.participants.length;
      if (participantCount > 0) {
        balance -= expense.amount / participantCount;
      }
    }
    
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Altri gruppi attivi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final balance = _calculateBalance(group);
              
              return GestureDetector(
                onTap: () => onGroupTap?.call(group),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        group.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        balance >= 0
                            ? '+${balance.toStringAsFixed(2)}€'
                            : '${balance.toStringAsFixed(2)}€',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: balance >= 0
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
