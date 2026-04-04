import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'group_card_header.dart';
import 'group_card_amounts.dart';
import 'group_card_empty_state.dart';
// group_card_stats.dart removed import (not needed here)
import 'add_expense_controller.dart';
import 'group_card_recents.dart';

/// Main content widget for expense group cards.
///
/// This is a composition of smaller, focused widgets:
/// - [GroupCardHeader] - Title and date range
/// - [GroupCardTotalAmount] - Total expenses display
/// - [GroupCardStats] - Charts and statistics
/// - [GroupCardAddButton] - Add expense button
class GroupCardContent extends StatefulWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
  });

  @override
  State<GroupCardContent> createState() => _GroupCardContentState();
}

class _GroupCardContentState extends State<GroupCardContent> {
  late ExpenseGroup _currentGroup;
  ExpenseGroupNotifier? _groupNotifier;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to notifier for updates
    _groupNotifier?.removeListener(_onGroupUpdated);
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onGroupUpdated);
  }

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onGroupUpdated);
    super.dispose();
  }

  void _onGroupUpdated() {
    // Only update if this specific group was modified
    if (_groupNotifier?.currentGroup?.id == widget.group.id) {
      if (mounted) {
        setState(() {
          _currentGroup = _groupNotifier!.currentGroup!;
        });
      }
    }
  }

  @override
  void didUpdateWidget(GroupCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update current group if the widget's group changed
    if (oldWidget.group.id != widget.group.id) {
      _currentGroup = widget.group;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addExpenseController = AddExpenseController(
      group: _currentGroup,
      onExpenseAdded: widget.onExpenseAdded,
      onCategoryAdded: widget.onCategoryAdded,
    );

    return LayoutBuilder(
      builder: (ctx2, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupCardHeader(
              group: _currentGroup,
              localizations: widget.localizations,
              theme: widget.theme,
            ),
            const Spacer(),
            // Show playful empty state or amounts based on expenses
            if (_currentGroup.expenses.isEmpty)
              GroupCardEmptyState(
                localizations: widget.localizations,
                theme: widget.theme,
              )
            else
              GroupCardAmounts(
                group: _currentGroup,
                theme: widget.theme,
                localizations: widget.localizations,
              ),
            const Spacer(),
            GroupCardRecents(
              key: ValueKey(
                'recents_${_currentGroup.id}_${_currentGroup.expenses.length}',
              ),
              group: _currentGroup,
              localizations: widget.localizations,
              theme: widget.theme,
            ),
            GroupCardAddButton(
              group: _currentGroup,
              theme: widget.theme,
              controller: addExpenseController,
            ),
          ],
        );
      },
    );
  }
}
