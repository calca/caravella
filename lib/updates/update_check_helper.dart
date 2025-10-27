import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/bottom_sheet_scaffold.dart';
import '../widgets/app_toast.dart';
import 'update_service_factory.dart';

/// Shows a bottom sheet recommending the user to update the app.
///
/// This is typically shown when an automatic weekly check detects
/// an available update.
Future<bool?> showUpdateRecommendationSheet(BuildContext context) async {
  final loc = gen.AppLocalizations.of(context);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => GroupBottomSheetScaffold(
      title: loc.update_available,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.update_available_desc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(loc.update_later),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.download),
                label: Text(loc.update_now),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Performs an automatic update check and shows recommendation sheet if needed.
///
/// This should be called when the app starts. It will:
/// 1. Check if enough time has passed since last check (7 days)
/// 2. If yes, check for updates
/// 3. If update available, show recommendation sheet
/// 4. If user accepts, start flexible update
/// 5. Record the check timestamp
Future<void> checkAndShowUpdateIfNeeded(BuildContext context) async {
  final updateService = UpdateServiceFactory.createUpdateService();

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

  final shouldUpdate = await showUpdateRecommendationSheet(context);

  // If user wants to update, start flexible update
  if (shouldUpdate == true) {
    await updateService.startFlexibleUpdate();

    if (!context.mounted) return;

    // Show toast to inform user
    AppToast.show(
      context,
      gen.AppLocalizations.of(context).update_downloading,
      type: ToastType.info,
      icon: Icons.download,
    );
  }
}
