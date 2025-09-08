import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'expense_form_state.dart';

/// Validation utilities for ExpenseFormComponent
class ExpenseFormValidation {
  // Private constructor to prevent instantiation
  ExpenseFormValidation._();
  
  /// Validates amount field
  static String? validateAmount(String? value, gen.AppLocalizations gloc) {
    if (value == null || value.trim().isEmpty) {
      return gloc.invalid_amount;
    }
    
    final parsed = parseLocalizedAmount(value);
    if (parsed == null || parsed <= 0) {
      return gloc.invalid_amount;
    }
    
    return null;
  }
  
  /// Validates name field
  static String? validateName(String? value, gen.AppLocalizations gloc) {
    if (value == null || value.trim().isEmpty) {
      return gloc.enter_title;
    }
    return null;
  }
  
  /// Checks if the entire form is valid
  static bool isFormValid(ExpenseFormState state) {
    return state.isFormValid();
  }
  
  /// Parses localized amount string to double
  static double? parseLocalizedAmount(String text) {
    if (text.trim().isEmpty) return null;
    
    String normalized = text.trim()
        .replaceAll(',', '.')  // Convert comma to dot for decimal
        .replaceAll(RegExp(r'[^\d.]'), ''); // Remove non-numeric chars except dot
    
    // Handle multiple dots (keep only the last one as decimal separator)
    if (normalized.contains('.')) {
      List<String> parts = normalized.split('.');
      if (parts.length > 2) {
        // Multiple dots - keep last as decimal, remove others
        String integerPart = parts.sublist(0, parts.length - 1).join('');
        String decimalPart = parts.last;
        normalized = '$integerPart.$decimalPart';
      }
    }
    
    try {
      return double.parse(normalized);
    } catch (e) {
      return null;
    }
  }
  
  /// Formats amount for display
  static String formatAmount(double amount, String? currency) {
    final symbol = currency ?? '€';
    return '${amount.toStringAsFixed(2)} $symbol';
  }
}