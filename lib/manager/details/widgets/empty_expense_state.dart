import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../l10n/app_localizations.dart' as gen;

/// A group with no expenses yet: a white card with a receipt icon, a short
/// title and line, and a wide "Add expense" button (same style as the rest
/// of the app — no emoji).
class EmptyExpenseState extends StatelessWidget {
  final VoidCallback onAddFirstExpense;

  const EmptyExpenseState({super.key, required this.onAddFirstExpense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final radius = BorderRadius.circular(24);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: CardOutline(
        borderRadius: radius,
        child: Material(
          color: s.raisedSurface,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.onSurface.withValues(alpha: 0.06),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 30,
                      color: s.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  gloc.empty_expenses_title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gloc.empty_expenses_subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: s.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onAddFirstExpense,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(gloc.add_first_expense_button),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                    elevation: 0,
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
