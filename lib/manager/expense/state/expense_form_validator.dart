import 'package:caravella_core/caravella_core.dart';
import 'expense_form_state.dart';

/// Pure validation functions for expense form
class ExpenseFormValidator {
  ExpenseFormValidator._();

  /// Validates amount field
  static bool isAmountValid(double? amount) {
    return amount != null && amount > 0;
  }

  /// Validates paid by field
  static bool isPaidByValid(ExpenseParticipant? paidBy) {
    return paidBy != null;
  }

  /// Validates category field
  static bool isCategoryValid(
    ExpenseCategory? category,
    List<ExpenseCategory> categories,
  ) {
    return categories.isEmpty || category != null;
  }

  /// Validates entire form
  static bool isFormValid(
    ExpenseFormState state,
    List<ExpenseCategory> categories,
  ) {
    return isAmountValid(state.amount) &&
        isPaidByValid(state.paidBy) &&
        isCategoryValid(state.category, categories);
  }

  /// Parses amount from string input
  static double? parseAmount(String text) {
    if (text.isEmpty) return null;
    // Replace comma with dot for decimal separator
    final normalized = text.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Validates and formats amount string
  static String? validateAmountString(String text) {
    if (text.isEmpty) return null;
    final amount = parseAmount(text);
    if (amount == null || amount <= 0) {
      return 'Invalid amount';
    }
    return null;
  }
}
