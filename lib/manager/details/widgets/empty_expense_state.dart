import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' as gen;

/// Enhanced empty state widget for when there are no expenses in a group.
/// Displays a welcoming image, encouraging message, and call-to-action button.
class EmptyExpenseState extends StatelessWidget {
  final VoidCallback onAddFirstExpense;

  const EmptyExpenseState({super.key, required this.onAddFirstExpense});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            Container(
              padding: const EdgeInsets.only(
                top: 0,
                left: 24,
                right: 24,
                bottom: 0,
              ),
              child: Image.asset(
                'assets/images/home/welcome/welcome-logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.receipt_long_outlined,
                    size: 120,
                    color: colorScheme.primary.withOpacity(0.6),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gloc.empty_expenses_title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              gloc.empty_expenses_subtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: content),
            ),
          ),
        );
      },
    );
  }
}
