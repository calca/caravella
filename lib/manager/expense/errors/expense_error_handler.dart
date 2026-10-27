import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Centralized error handling for expense module
///
/// Provides consistent, localized error messaging using AppToast for
/// expense-related operations. Technical details go to the log, not to the
/// user.
class ExpenseErrorHandler {
  ExpenseErrorHandler._();

  // Attachment errors

  static void showAttachmentLimitError(
    BuildContext context, {
    required int maxCount,
  }) {
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).attachment_limit(maxCount),
      type: ToastType.error,
    );
  }

  static void showAttachmentAddError(BuildContext context, Object error) {
    LoggerService.warning('Adding an attachment failed: $error', name: 'ui');
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).attachment_add_error,
      type: ToastType.error,
    );
  }

  static void showAttachmentShareError(BuildContext context, Object error) {
    LoggerService.warning('Sharing an attachment failed: $error', name: 'ui');
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).attachment_share_error,
      type: ToastType.error,
    );
  }

  // Location errors

  static void showLocationPermissionDenied(BuildContext context) {
    _showLocationError(
      context,
      gen.AppLocalizations.of(context).location_permission_denied,
    );
  }

  static void showLocationPermissionDeniedForever(BuildContext context) {
    _showLocationError(
      context,
      gen.AppLocalizations.of(context).location_permission_denied_forever,
    );
  }

  static void showLocationServiceDisabled(BuildContext context) {
    _showLocationError(
      context,
      gen.AppLocalizations.of(context).location_service_disabled,
    );
  }

  /// No position (timeout, or [error] while retrieving it).
  static void showLocationRetrievalError(
    BuildContext context, [
    Object? error,
  ]) {
    if (error != null) {
      LoggerService.warning('Location retrieval failed: $error', name: 'ui');
    }
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).location_error,
      type: ToastType.error,
    );
  }

  static void _showLocationError(BuildContext context, String message) {
    AppToast.show(
      context,
      message,
      type: ToastType.error,
      duration: const Duration(seconds: 5),
    );
  }
}
