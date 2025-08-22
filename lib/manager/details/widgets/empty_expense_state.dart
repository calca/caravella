import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart' as gen;

/// Enhanced empty state widget for when there are no expenses in a group.
/// Displays a welcoming image, encouraging message, and call-to-action button.
class EmptyExpenseState extends StatelessWidget {
  final VoidCallback onAddFirstExpense;

  const EmptyExpenseState({
    super.key,
    required this.onAddFirstExpense,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gloc = gen.AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcoming illustration - using the existing welcome logo
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              'assets/images/home/welcome/welcome-logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if image fails to load
                return Icon(
                  Icons.receipt_long_outlined,
                  size: 120,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Encouraging title
          Text(
            gloc.empty_expenses_title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle with friendly messaging
          Text(
            gloc.empty_expenses_subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Call-to-action button
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}