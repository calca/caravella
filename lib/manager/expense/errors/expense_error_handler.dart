import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Centralized error handling for expense module
///
/// Provides consistent error messaging using AppToast for all
/// expense-related operations.
class ExpenseErrorHandler {
  ExpenseErrorHandler._();

  // Attachment errors

  static void showAttachmentLimitError(
    BuildContext context, {
    required int maxCount,
  }) {
    AppToast.show(
      context,
      'Maximum $maxCount attachments allowed',
      type: ToastType.error,
    );
  }

  static void showAttachmentPickError(
    BuildContext context,
    String errorDetails,
  ) {
    AppToast.show(
      context,
      'Error picking attachment: $errorDetails',
      type: ToastType.error,
    );
  }

  static void showAttachmentCompressionError(BuildContext context) {
    AppToast.show(context, 'Error compressing image', type: ToastType.error);
  }

  static void showAttachmentShareError(
    BuildContext context,
    String errorDetails,
  ) {
    AppToast.show(
      context,
      'Error sharing: $errorDetails',
      type: ToastType.error,
    );
  }

  // Location errors

  static void showLocationPermissionDenied(BuildContext context) {
    _showLocationErrorWithMessenger(
      context,
      'Location permission denied\nPlease enable location permissions in settings',
    );
  }

  static void showLocationPermissionDeniedForever(BuildContext context) {
    _showLocationErrorWithMessenger(
      context,
      'Location permission permanently denied\nPlease enable location permissions in system settings',
    );
  }

  static void showLocationServiceDisabled(BuildContext context) {
    _showLocationErrorWithMessenger(
      context,
      'Location service disabled\nPlease enable location services in settings',
    );
  }

  static void showLocationRetrievalError(
    BuildContext context,
    String errorDetails,
  ) {
    AppToast.show(
      context,
      'Error retrieving location: $errorDetails',
      type: ToastType.error,
    );
  }

  static void showLocationTimeoutError(BuildContext context) {
    AppToast.show(context, 'Location request timed out', type: ToastType.error);
  }

  static void _showLocationErrorWithMessenger(
    BuildContext context,
    String message,
  ) {
    AppToast.show(
      context,
      message,
      type: ToastType.error,
      duration: const Duration(seconds: 5),
    );
  }

  // Place search errors

  static void showPlaceSearchError(BuildContext context, String errorDetails) {
    AppToast.show(
      context,
      'Error searching places: $errorDetails',
      type: ToastType.error,
    );
  }

  static void showPlaceSearchEmptyError(BuildContext context) {
    AppToast.show(context, 'No places found', type: ToastType.info);
  }

  // Form validation errors

  static void showFormValidationError(BuildContext context) {
    AppToast.show(
      context,
      'Please fill all required fields',
      type: ToastType.error,
    );
  }

  static void showAmountValidationError(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    AppToast.show(context, loc.invalid_amount, type: ToastType.error);
  }

  // Generic errors

  static void showGenericError(BuildContext context, String errorDetails) {
    AppToast.show(context, 'Error: $errorDetails', type: ToastType.error);
  }

  // Success messages

  static void showExpenseSaved(BuildContext context) {
    AppToast.show(
      context,
      'Expense saved successfully',
      type: ToastType.success,
    );
  }

  static void showExpenseDeleted(BuildContext context) {
    AppToast.show(context, 'Expense deleted', type: ToastType.success);
  }
}
