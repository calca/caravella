import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import '../../../manager/detail_page/trip_detail_page.dart';
import '../../../widgets/widgets.dart';

class GroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;

  const GroupCard({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
  });

  String _formatDateRange(ExpenseGroup group, AppLocalizations loc) {
    final start = group.startDate;
    final end = group.endDate;

    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Dal ${_formatDate(start)}';
    } else if (end != null) {
      return 'Fino al ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = group.expenses
        .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    final participantCount = group.participants.length;

    return BaseCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(trip: group),
          ),
        );
        if (result == true) {
          onGroupUpdated();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header della card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (group.pinned)
                Icon(
                  Icons.push_pin,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Info del gruppo
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                '$participantCount ${localizations.get('participants').toLowerCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                '${group.expenses.length} ${localizations.get('expenses').toLowerCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          if (group.startDate != null || group.endDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDateRange(group, localizations),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Totale spese
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.euro,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '€${totalExpenses.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
