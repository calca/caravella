import 'package:material_ui/material_ui.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'update_service_factory.dart';
import 'update_service_interface.dart';
import 'update_localizations.dart';

/// Shows a bottom sheet recommending the user to update the app.
///
/// This is typically shown when an automatic weekly check detects
/// an available update.
Future<bool?> showUpdateRecommendationSheet(
  BuildContext context,
  UpdateLocalizations localizations,
  Widget Function(BuildContext, {required String title, required Widget child})
  bottomSheetBuilder,
) async {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => bottomSheetBuilder(
      context,
      title: localizations.updateAvailable,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            localizations.updateAvailableDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.download_rounded),
            label: Text(localizations.updateNow),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(localizations.updateLater),
          ),
        ],
      ),
    ),
  );
}

/// Shows a bottom sheet prompting the user to install a flexible update
/// that already finished downloading (e.g. from a previous session).
Future<void> _promptInstallReadyUpdate(
  BuildContext context,
  UpdateService updateService,
  UpdateLocalizations localizations,
  Widget Function(BuildContext, {required String title, required Widget child})
  bottomSheetBuilder,
) async {
  final shouldInstall = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => bottomSheetBuilder(
      context,
      title: localizations.updateReadyToInstall,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            localizations.updateReadyToInstallDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(localizations.updateInstall),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(localizations.updateLater),
          ),
        ],
      ),
    ),
  );

  if (shouldInstall == true) {
    await updateService.completeFlexibleUpdate();
  }
}

/// Performs an automatic update check and shows recommendation sheet if needed.
///
/// This should be called when the app starts. It will:
/// 0. If a previously started flexible update already finished downloading,
///    prompt to install it (regardless of the check interval below)
/// 1. Check if enough time has passed since last check (7 days)
/// 2. If yes, check for updates
/// 3. If update available, show recommendation sheet
/// 4. If user accepts, start flexible update (toast when the download starts)
/// 5. When the download finishes, prompt to install (restarts the app)
/// 6. Record the check timestamp
Future<void> checkAndShowUpdateIfNeeded(
  BuildContext context,
  UpdateLocalizations localizations,
  Widget Function(BuildContext, {required String title, required Widget child})
  bottomSheetBuilder,
) async {
  final updateService = UpdateServiceFactory.createUpdateService();

  if (await updateService.isUpdateReadyToInstall()) {
    if (!context.mounted) return;
    await _promptInstallReadyUpdate(
      context,
      updateService,
      localizations,
      bottomSheetBuilder,
    );
    return;
  }

  // Check if we should perform an update check
  final shouldCheck = await updateService.shouldCheckForUpdate();
  if (!shouldCheck) {
    return;
  }

  // Check for update
  final updateInfo = await updateService.checkForUpdate();

  // Record that we checked (even if no update available)
  await updateService.recordUpdateCheck();

  // If no update, return
  if (updateInfo == null) {
    return;
  }

  // Wait a bit to let the app settle before showing the sheet
  await Future.delayed(const Duration(milliseconds: 500));

  // Show recommendation sheet
  if (!context.mounted) return;

  final shouldUpdate = await showUpdateRecommendationSheet(
    context,
    localizations,
    bottomSheetBuilder,
  );

  if (shouldUpdate != true) return;

  // Completes only when the download has finished (or was declined/failed),
  // so the user keeps using the app meanwhile and gets the install prompt at
  // the end — without having to restart the app to see it.
  final downloaded = await updateService.startFlexibleUpdate(
    onDownloadStarted: () {
      if (!context.mounted) return;
      AppToast.show(
        context,
        localizations.updateDownloading,
        type: ToastType.info,
        icon: Icons.download,
      );
    },
  );

  if (!downloaded || !context.mounted) return;
  await _promptInstallReadyUpdate(
    context,
    updateService,
    localizations,
    bottomSheetBuilder,
  );
}
