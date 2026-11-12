import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

/// A permission Caravella asked for and the system now refuses.
enum DeniedPermission {
  camera,

  /// The camera, for the QR code on the Join a group page.
  cameraForQr,

  /// The microphone, for adding an expense by voice.
  microphone,
  photos,
  notifications,
  location,
}

/// "Allow the camera?": what the permission is for, that it's off, and
/// "Open settings" (the app's page in the system settings) or "Not now".
/// Instead of a toast, which had nothing to tap. `true` when the settings
/// were opened, so the caller can try again once the app is back.
Future<bool> showPermissionDeniedDialog(
  BuildContext context,
  DeniedPermission permission,
) async {
  final gloc = gen.AppLocalizations.of(context);
  final (title, message) = switch (permission) {
    DeniedPermission.camera => (
      gloc.permission_camera_title,
      gloc.permission_camera_message,
    ),
    DeniedPermission.cameraForQr => (
      gloc.permission_camera_title,
      gloc.permission_camera_qr_message,
    ),
    DeniedPermission.microphone => (
      gloc.permission_microphone_title,
      gloc.permission_microphone_message,
    ),
    DeniedPermission.photos => (
      gloc.permission_photos_title,
      gloc.permission_photos_message,
    ),
    DeniedPermission.notifications => (
      gloc.permission_notifications_title,
      gloc.permission_notifications_message,
    ),
    DeniedPermission.location => (
      gloc.permission_location_title,
      gloc.permission_location_message,
    ),
  };
  final open = await showDialog<bool>(
    context: context,
    builder: (ctx) => Material3Dialog(
      title: Text(title),
      content: Text(message),
      actions: [
        Material3DialogActions.cancel(ctx, gloc.permission_not_now),
        Material3DialogActions.primary(
          ctx,
          gloc.permission_open_settings,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  if (open != true) return false;
  try {
    return await openAppSettings();
  } catch (e) {
    LoggerService.warning('Could not open the app settings: $e', name: 'ui');
    return false;
  }
}
