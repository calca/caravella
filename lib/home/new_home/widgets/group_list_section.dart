import 'package:flutter/material.dart';
import '../../models/group_item.dart';
import 'group_card_widget.dart';

/// Section displaying active groups with a title and action button.
class GroupListSection extends StatelessWidget {
  /// List of groups to display
  final List<GroupItem> groups;
  
  /// Callback when "Vedi tutti" is tapped
  final VoidCallback? onViewAll;
  
  /// Callback when a group card is tapped
  final void Function(GroupItem group)? onGroupTap;

  const GroupListSection({
    super.key,
    required this.groups,
    this.onViewAll,
    this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gruppi Attivi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        'Vedi tutti',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Groups list
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Text(
                'Nessun gruppo attivo',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GroupCardWidget(
                  group: group,
                  onTap: () => onGroupTap?.call(group),
                ),
              );
            },
          ),
      ],
    );
  }
}
