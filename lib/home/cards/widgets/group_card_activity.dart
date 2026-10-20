import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'group_card_get_started.dart';
import 'group_card_recents.dart';

/// The second card on Home: the last three expenses and "See all", which
/// opens the group. With no expenses yet, the getting-started checklist.
class GroupCardActivity extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  /// Opens the group page.
  final VoidCallback onSeeAll;

  /// Opens the add-expense sheet (checklist step).
  final VoidCallback onAddExpense;

  const GroupCardActivity({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onSeeAll,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (group.expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: GroupCardGetStarted(
          group: group,
          theme: theme,
          localizations: localizations,
          onAddExpense: onAddExpense,
        ),
      );
    }

    final s = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GroupCardRecents(
            key: ValueKey('recents_${group.id}_${group.expenses.length}'),
            group: group,
            localizations: localizations,
            theme: theme,
            count: GroupCardRecents.maxCount,
          ),
          Divider(height: 1, color: s.outlineVariant),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: s.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.see_all,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: s.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 20, color: s.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
