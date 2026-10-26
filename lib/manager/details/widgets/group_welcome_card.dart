import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// One-time card on a group received from another device: who shared it
/// ([from], empty when unknown), how many people and expenses it has and
/// its total so far, then "OK" and "Add expense". Both dismiss it for good.
class GroupWelcomeCard extends StatelessWidget {
  final ExpenseGroup group;
  final String from;
  final VoidCallback onDismiss;
  final VoidCallback onAddExpense;

  const GroupWelcomeCard({
    super.key,
    required this.group,
    required this.from,
    required this.onDismiss,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final people = gloc.participant_count(group.participants.length);
    final expenses = gloc.expense_count(group.expenses.length);
    final total = CurrencyDisplay.formatCurrencyText(
      group.getTotalExpenses(),
      group.currency,
    );
    final radius = BorderRadius.circular(20);
    final initials = from.trim().isEmpty
        ? null
        : from
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w.characters.first.toUpperCase())
              .join();

    return Material(
      color: s.raisedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: s.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.onSurface.withValues(alpha: 0.06),
                  ),
                  child: initials == null
                      ? Icon(
                          Icons.group_add_outlined,
                          size: 20,
                          color: s.onSurface,
                        )
                      : Text(
                          initials,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      gloc.group_welcome_title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              from.trim().isEmpty
                  ? gloc.group_welcome_body_anon(people, expenses, total)
                  : gloc.group_welcome_body(from, people, expenses, total),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: s.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onDismiss,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: const StadiumBorder(),
                      elevation: 0,
                      backgroundColor: s.onSurface.withValues(alpha: 0.06),
                      foregroundColor: s.onSurface,
                    ),
                    child: Text(gloc.ok),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddExpense,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(gloc.add_first_expense_button),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: const StadiumBorder(),
                      backgroundColor: s.primary,
                      foregroundColor: s.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
