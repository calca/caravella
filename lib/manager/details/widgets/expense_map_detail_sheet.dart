import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'expense_amount_card.dart';

/// Bottom sheet that displays expense details when clicking on a map marker
class ExpenseMapDetailSheet extends StatelessWidget {
  final List<ExpenseDetails> expenses;
  final String currency;

  const ExpenseMapDetailSheet({
    super.key,
    required this.expenses,
    required this.currency,
  });

  String _formatLocationAddress(ExpenseLocation? location) {
    if (location == null) return '';

    // Build full address from structured components (same as location_input_widget)
    final addressParts = <String>[
      if (location.name != null && location.name!.isNotEmpty) location.name!,
      if (location.street != null && location.street!.isNotEmpty)
        location.street!,
      if (location.streetNumber != null && location.streetNumber!.isNotEmpty)
        location.streetNumber!,
      if (location.locality != null && location.locality!.isNotEmpty)
        location.locality!,
      if (location.administrativeArea != null &&
          location.administrativeArea!.isNotEmpty)
        location.administrativeArea!,
      if (location.postalCode != null && location.postalCode!.isNotEmpty)
        location.postalCode!,
      if (location.country != null && location.country!.isNotEmpty)
        location.country!,
    ];

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : location.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    final firstExpense = expenses.first;
    final locationAddress = _formatLocationAddress(firstExpense.location);
    final fullAddress = locationAddress.isNotEmpty
        ? locationAddress
        : '${firstExpense.location?.latitude?.toStringAsFixed(6)}, ${firstExpense.location?.longitude?.toStringAsFixed(6)}';

    return GroupBottomSheetScaffold(
      title: gloc.location,
      scrollable: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full address display (like in location_input_widget)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(fullAddress, style: theme.textTheme.bodyLarge),
          ),

          // Coordinates if available
          if (firstExpense.location?.latitude != null &&
              firstExpense.location?.longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                '${firstExpense.location!.latitude!.toStringAsFixed(6)}, ${firstExpense.location!.longitude!.toStringAsFixed(6)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          const SizedBox(height: 8),
          // Location count badge
          if (expenses.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  gloc.expense_count(expenses.length),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // List of expenses at this location
          ...expenses.map((expense) {
            return ExpenseAmountCard(
              title: expense.name ?? expense.category.name,
              amount: expense.amount ?? 0,
              checked: false,
              paidBy: expense.paidBy,
              category: expense.category.name,
              date: expense.date,
              currency: currency,
            );
          }),
        ],
      ),
    );
  }
}
