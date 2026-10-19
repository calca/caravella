import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../../../manager/group/group_edit_mode.dart';
import '../../../manager/group/pages/expense_group_other_page.dart';
import '../../../manager/group/pages/expense_group_participants_page.dart';

/// Getting-started checklist shown on the Home card while the group has no
/// expenses: create the group (done), add the first expense, add the
/// participants, choose a photo or a color. Steps tick themselves as the
/// group changes; the first expense replaces the checklist with the amounts.
class GroupCardGetStarted extends StatelessWidget {
  final ExpenseGroup group;
  final ThemeData theme;
  final gen.AppLocalizations localizations;
  final VoidCallback onAddExpense;

  const GroupCardGetStarted({
    super.key,
    required this.group,
    required this.theme,
    required this.localizations,
    required this.onAddExpense,
  });

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final s = theme.colorScheme;
    final t = theme.textTheme;
    final loc = localizations;

    final hasLook = (group.file?.isNotEmpty ?? false) || group.color != null;
    final steps = [
      (Icons.group_add_outlined, loc.get_started_create_group, true, null),
      (Icons.add, loc.get_started_first_expense, false, onAddExpense),
      (
        Icons.person_add_alt_outlined,
        loc.get_started_participants,
        group.participants.length >= 2,
        () => _open(
          context,
          ExpenseGroupParticipantsPage(trip: group, mode: GroupEditMode.edit),
        ),
      ),
      (
        Icons.image_outlined,
        loc.get_started_look,
        hasLook,
        () => _open(
          context,
          ExpenseGroupOtherPage(trip: group, mode: GroupEditMode.edit),
        ),
      ),
    ];
    final done = steps.where((step) => step.$3).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            loc.get_started_title,
            style: t.titleLarge?.copyWith(
              color: s.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.get_started_progress(done, steps.length),
          style: t.bodyMedium?.copyWith(color: s.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        for (final (icon, label, isDone, onTap) in steps)
          _Step(
            icon: icon,
            label: label,
            done: isDone,
            doneLabel: loc.get_started_step_done(label),
            theme: theme,
            onTap: isDone ? null : onTap,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String label;
  final String doneLabel;
  final bool done;
  final ThemeData theme;
  final VoidCallback? onTap;

  const _Step({
    required this.icon,
    required this.label,
    required this.doneLabel,
    required this.done,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = theme.colorScheme;
    return Semantics(
      button: onTap != null,
      label: done ? doneLabel : label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? s.primary : s.surfaceContainerHighest,
                ),
                child: Icon(
                  done ? Icons.check_rounded : icon,
                  size: 20,
                  color: done ? s.onPrimary : s.onSurface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: done ? s.onSurfaceVariant : s.onSurface,
                    fontWeight: done ? FontWeight.w400 : FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: s.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
