import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' as gen;
import '../../../home/cards/widgets/group_card_empty_state.dart';

/// Enhanced empty state widget for when there are no expenses in a group.
/// Displays a welcoming image, encouraging message, and call-to-action button.
class EmptyExpenseState extends StatelessWidget {
  final VoidCallback onAddFirstExpense;

  const EmptyExpenseState({super.key, required this.onAddFirstExpense});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gloc = gen.AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final bottomInset = mediaQuery.viewPadding.bottom;
        final content = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Playful empty state with random emoji and message
            GroupCardEmptyState(localizations: gloc, theme: Theme.of(context)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAddFirstExpense,
              icon: const Icon(Icons.add_rounded),
              label: Text(gloc.add_first_expense_button),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 24 + bottomInset),
          ],
        );
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Center(child: content),
            ),
          ),
        );
      },
    );
  }
}
