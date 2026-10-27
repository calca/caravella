import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import '../../../manager/details/pages/expense_group_detail_page.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'add_expense_controller.dart';
import 'group_card_activity.dart';
import 'group_card_content.dart';

/// The featured group on Home, as two cards: the group itself (title, dates,
/// total, today, spending wave — [GroupCardContent]) filling the space, and
/// below it the last expenses with "See all" ([GroupCardActivity]).
///
/// The group's photo or color only goes on the first card.
class GroupCard extends StatefulWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupUpdated;
  final VoidCallback? onCategoryAdded;

  /// Whether this group's data is fully synced with peers.
  final bool? isSynced;

  /// Whether the card shows its own "Add expense" button. Off on Home, where
  /// the round button next to the floating navigation does it.
  final bool showAddButton;

  const GroupCard({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onGroupUpdated,
    this.onCategoryAdded,
    this.isSynced,
    this.showAddButton = true,
  });

  /// Space between the two cards.
  static const double gap = 12;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  late ExpenseGroup _group;
  ExpenseGroupNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier?.removeListener(_onNotifierChanged);
    _notifier = context.read<ExpenseGroupNotifier>();
    _notifier?.addListener(_onNotifierChanged);
  }

  @override
  void didUpdateWidget(GroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Any new instance: the Home reloads a group after its participants,
    // photo or color change, and the checklist must follow.
    if (!identical(oldWidget.group, widget.group)) _group = widget.group;
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onNotifierChanged() {
    final current = _notifier?.currentGroup;
    // Opening the add sheet sets this very group as current: nothing changed,
    // and rebuilding the card under the sliding sheet made it stutter.
    if (current != null &&
        current.id == widget.group.id &&
        !identical(current, _group) &&
        mounted) {
      setState(() => _group = current);
    }
  }

  Future<void> _openGroup() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseGroupDetailPage(trip: _group)),
    );
    if (result == true) widget.onGroupUpdated();
  }

  void _addExpense() => AddExpenseController(
    group: _group,
    onExpenseAdded: widget.onGroupUpdated,
    onCategoryAdded: widget.onCategoryAdded,
  ).showAddExpenseSheet(context, _group);

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bg = GroupBackgroundUtils.resolve(
      _group,
      theme.colorScheme,
      baseColor: theme.colorScheme.surface,
    );
    final photo = bg.hasImage ? bg.imagePath : null;
    final radius = BorderRadius.circular(32);

    final groupCard = CardOutline(
      borderRadius: radius,
      child: BaseCard(
        isFlat: false,
        noBorder: true, // CardOutline draws the edge
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        borderRadius: radius,
        backgroundColor: photo != null ? theme.colorScheme.surface : bg.color,
        backgroundGradient: photo != null ? null : bg.gradient,
        onTap: _openGroup,
        // The header carries the "open group" action for screen readers.
        mergeSemantics: false,
        child: ClipRRect(
          borderRadius: radius,
          child: GroupCardContent(
            onOpen: _openGroup,
            group: _group,
            localizations: widget.localizations,
            theme: theme,
            onExpenseAdded: widget.onGroupUpdated,
            showAddButton: widget.showAddButton,
            onCategoryAdded: widget.onCategoryAdded,
            isSynced: widget.isSynced,
            photoPath: photo,
          ),
        ),
      ),
    );

    final activityCard = CardOutline(
      borderRadius: radius,
      child: BaseCard(
        isFlat: false,
        noBorder: true,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        borderRadius: radius,
        backgroundColor: theme.colorScheme.surface,
        mergeSemantics: false,
        child: GroupCardActivity(
          group: _group,
          localizations: widget.localizations,
          theme: theme,
          onSeeAll: _openGroup,
          onAddExpense: _addExpense,
        ),
      ),
    );

    // Fills the height Home gives it; with large text Home gives none and
    // the card is as tall as its content.
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: constraints.hasBoundedHeight
            ? MainAxisSize.max
            : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (constraints.hasBoundedHeight)
            Expanded(child: groupCard)
          else
            groupCard,
          const SizedBox(height: GroupCard.gap),
          activityCard,
        ],
      ),
    );
  }
}
