import 'dart:io';
import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/settings/widgets/settings_card.dart';
import 'update_service_factory.dart';
import 'update_service_interface.dart';

/// Widget for displaying update check functionality in settings.
///
/// This widget handles all the update-related UI logic including:
/// - Checking for updates
/// - Displaying update status
/// - Starting update downloads
/// - Platform detection
///
/// On non-Android platforms, returns an empty SizedBox to hide completely.
class UpdateCheckWidget extends StatelessWidget {
  const UpdateCheckWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Hide completely on non-Android platforms
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    final loc = gen.AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<UpdateNotifier>(
      create: (_) => UpdateServiceFactory.createUpdateNotifier(),
      child: Consumer<UpdateNotifier>(
        builder: (context, notifier, _) {
          // Show prominent card when update is available
          if (notifier.updateAvailable) {
            return _buildUpdateAvailableCard(
              context,
              loc,
              notifier,
              colorScheme,
              textTheme,
            );
          }

          // Show compact card for normal state
          return SettingsCard(
            context: context,
            color: colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: Text(loc.check_for_updates, style: textTheme.titleMedium),
              subtitle: _buildUpdateSubtitle(context, loc, notifier),
              trailing: _buildUpdateTrailing(context, loc, notifier),
              onTap: notifier.isChecking ||
                      notifier.isDownloading ||
                      notifier.isInstalling
                  ? null
                  : () => _handleUpdateCheck(context, loc, notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpdateAvailableCard(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Icon(
                    Icons.system_update,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.update_available,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (notifier.availableVersion != null)
                        Text(
                          'v${notifier.availableVersion}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              loc.update_available_desc(notifier.availableVersion ?? ''),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!notifier.isDownloading && !notifier.isInstalling)
                  TextButton(
                    onPressed: () => _handleUpdateCheck(context, loc, notifier),
                    child: Text(loc.update_later),
                  ),
                if (!notifier.isDownloading && !notifier.isInstalling)
                  const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: notifier.isDownloading || notifier.isInstalling
                      ? null
                      : () => _handleStartUpdate(context, loc, notifier),
                  icon: notifier.isDownloading || notifier.isInstalling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    notifier.isDownloading
                        ? loc.update_downloading
                        : notifier.isInstalling
                            ? loc.update_installing
                            : loc.update_now,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateSubtitle(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
  ) {
    final textTheme = Theme.of(context).textTheme;

    if (notifier.isChecking) {
      return Text(loc.checking_for_updates, style: textTheme.bodySmall);
    }

    if (notifier.isDownloading) {
      return Text(loc.update_downloading, style: textTheme.bodySmall);
    }

    if (notifier.isInstalling) {
      return Text(loc.update_installing, style: textTheme.bodySmall);
    }

    if (notifier.error != null) {
      return Text(
        loc.update_error,
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    if (notifier.updateAvailable) {
      return Text(
        loc.update_available_desc(notifier.availableVersion ?? ''),
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Text(loc.check_for_updates_desc, style: textTheme.bodySmall);
  }

  Widget? _buildUpdateTrailing(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
  ) {
    if (notifier.isChecking ||
        notifier.isDownloading ||
        notifier.isInstalling) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (notifier.updateAvailable) {
      return FilledButton(
        onPressed: () => _handleStartUpdate(context, loc, notifier),
        child: Text(loc.update_now),
      );
    }

    return const Icon(Icons.arrow_forward_ios, size: 16);
  }

  Future<void> _handleUpdateCheck(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
  ) async {
    await notifier.checkForUpdate();

    if (!context.mounted) return;

    if (notifier.error != null) {
      AppToast.show(context, loc.update_error, type: ToastType.error);
    } else if (!notifier.updateAvailable) {
      AppToast.show(context, loc.no_update_available, type: ToastType.info);
    }
  }

  Future<void> _handleStartUpdate(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
  ) async {
    // Start flexible update (allows background download)
    final success = await notifier.startFlexibleUpdate();

    if (!context.mounted) return;

    if (success) {
      AppToast.show(
        context,
        loc.update_downloading,
        type: ToastType.info,
        icon: Icons.download,
      );
    } else if (notifier.error != null) {
      AppToast.show(context, loc.update_error, type: ToastType.error);
    }
  }
}
