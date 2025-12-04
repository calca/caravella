import 'package:caravella_core/caravella_core.dart';
import '../state/expense_form_state.dart';

/// Centralized validation service for expense forms
///
/// Provides pure validation functions that can be easily tested
/// and reused across different components.
class ExpenseValidationService {
  ExpenseValidationService._();

  // Amount validation

  /// Validates that amount is present and positive
  static bool isAmountValid(double? amount) {
    return amount != null && amount > 0;
  }

  /// Validates amount string and returns error message
  static String? validateAmountString(String? text, String errorMessage) {
    if (text == null || text.isEmpty) return errorMessage;
    final amount = parseAmount(text);
    if (amount == null || amount <= 0) return errorMessage;
    return null;
  }

  /// Parses amount from string, handling both comma and dot as decimal separator
  static double? parseAmount(String text) {
    if (text.isEmpty) return null;
    final normalized = text.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  // Name validation

  /// Validates that name is not empty
  static bool isNameValid(String? name) {
    return name != null && name.trim().isNotEmpty;
  }

  /// Validates name string and returns error message
  static String? validateNameString(String? text, String errorMessage) {
    if (text == null || text.trim().isEmpty) return errorMessage;
    return null;
  }

  // Participant validation

  /// Validates that paid-by participant is selected
  static bool isPaidByValid(ExpenseParticipant? paidBy) {
    return paidBy != null;
  }

  // Category validation

  /// Validates category field based on whether categories exist
  static bool isCategoryValid(
    ExpenseCategory? category,
    List<ExpenseCategory> availableCategories,
  ) {
    return availableCategories.isEmpty || category != null;
  }

  // Attachment validation

  /// Validates attachment file path exists
  static bool isAttachmentPathValid(String? path) {
    return path != null && path.isNotEmpty;
  }

  /// Validates attachment count is within limits
  static bool isAttachmentCountValid(int count, int maxCount) {
    return count <= maxCount;
  }

  // Location validation

  /// Validates location has required coordinates
  static bool isLocationValid(ExpenseLocation? location) {
    if (location == null) return true; // Location is optional
    return location.latitude != 0.0 || location.longitude != 0.0;
  }

  // Form validation

  /// Validates entire expense form
  static bool isFormValid(
    ExpenseFormState state,
    List<ExpenseCategory> categories,
  ) {
    return isAmountValid(state.amount) &&
        isPaidByValid(state.paidBy) &&
        isCategoryValid(state.category, categories);
  }

  /// Returns list of validation errors for debugging
  static List<String> getValidationErrors(
    ExpenseFormState state,
    List<ExpenseCategory> categories,
  ) {
    final errors = <String>[];

    if (!isAmountValid(state.amount)) {
      errors.add('Invalid amount');
    }
    if (!isPaidByValid(state.paidBy)) {
      errors.add('Missing paid-by participant');
    }
    if (!isCategoryValid(state.category, categories)) {
      errors.add('Missing category');
    }

    return errors;
  }
}
