import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import '../data/group_form_state.dart';
import 'group_title_field.dart';

/// Reusable widget that displays a group name input field with an icon
/// representing the selected group type. The icon is tappable to change
/// the group type.
class GroupNameWithIconField extends StatelessWidget {
  final VoidCallback onIconTap;

  const GroupNameWithIconField({super.key, required this.onIconTap});

  @override
  Widget build(BuildContext context) {
    return Selector<GroupFormState, ExpenseGroupType?>(
      selector: (context, s) => s.groupType,
      builder: (context, groupType, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onIconTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                groupType?.icon ?? Icons.category_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: GroupTitleField()),
        ],
      ),
    );
  }
}
