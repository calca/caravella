import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/group_item.dart';

/// Individual card widget for displaying a group item.
class GroupCardWidget extends StatelessWidget {
  /// The group to display
  final GroupItem group;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  /// Currency symbol to display
  final String currency;

  const GroupCardWidget({
    super.key,
    required this.group,
    this.onTap,
    this.currency = '€',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(group.status);
    final isPositive = group.status == GroupStatus.positive;
    final isSettled = group.status == GroupStatus.settled;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Emoji or placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    group.emoji ?? '📊',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLastActivity(group.lastActivity),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isSettled
                        ? 'Saldato'
                        : '${isPositive ? '+' : ''}${group.amount.toStringAsFixed(2)} $currency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!isSettled) ...[
                    const SizedBox(height: 2),
                    Text(
                      isPositive ? 'Ti devono' : 'Devi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(GroupStatus status) {
    switch (status) {
      case GroupStatus.positive:
        return const Color(0xFF2ECC71); // Green
      case GroupStatus.negative:
        return const Color(0xFFE74C3C); // Red
      case GroupStatus.settled:
        return const Color(0xFF95A5A6); // Gray
    }
  }

  String _formatLastActivity(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return DateFormat('dd MMM yyyy', 'it').format(date);
    }
  }
}
