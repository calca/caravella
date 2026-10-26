import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../l10n/app_localizations.dart' as gen;

/// A group with no expenses yet: an [EmptyStateCard] with a receipt icon, a
/// short title and line, and a wide "Add expense" button.
class EmptyExpenseState extends StatelessWidget {
  final VoidCallback onAddFirstExpense;

  const EmptyExpenseState({super.key, required this.onAddFirstExpense});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: EmptyStateCard(
        icon: Icons.receipt_long_outlined,
        title: gloc.empty_expenses_title,
        subtitle: gloc.empty_expenses_subtitle,
        actionLabel: gloc.add_first_expense_button,
        onAction: onAddFirstExpense,
      ),
    );
  }
}
