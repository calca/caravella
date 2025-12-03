import 'dart:io';
import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'update_service_factory.dart';
import 'update_service_interface.dart';
import 'update_localizations.dart';

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
  final UpdateLocalizations localizations;
  final Widget Function(BuildContext, Widget) cardBuilder;

  const UpdateCheckWidget({
    super.key,
    required this.localizations,
    required this.cardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Hide completely on non-Android platforms
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

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
              notifier,
              colorScheme,
              textTheme,
            );
          }

          // Show compact card for normal state
          return cardBuilder(
            context,
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: Text(
                localizations.checkForUpdates,
                style: textTheme.titleMedium,
              ),
              subtitle: _buildUpdateSubtitle(context, notifier),
              trailing: _buildUpdateTrailing(context, notifier),
              onTap: notifier.isChecking ||
                      notifier.isDownloading ||
                      notifier.isInstalling
                  ? null
                  : () => _handleUpdateCheck(context, notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpdateAvailableCard(
    BuildContext context,
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
                        localizations.updateAvailable,
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
              localizations.updateAvailableDesc,
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
                    onPressed: () => _handleUpdateCheck(context, notifier),
                    child: Text(localizations.updateLater),
                  ),
                if (!notifier.isDownloading && !notifier.isInstalling)
                  const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: notifier.isDownloading || notifier.isInstalling
                      ? null
                      : () => _handleStartUpdate(context, notifier),
                  icon: notifier.isDownloading || notifier.isInstalling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    notifier.isDownloading
                        ? localizations.updateDownloading
                        : notifier.isInstalling
                            ? localizations.updateInstalling
                            : localizations.updateNow,
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
    UpdateNotifier notifier,
  ) {
    final textTheme = Theme.of(context).textTheme;

    if (notifier.isChecking) {
      return Text(localizations.checkingForUpdates, style: textTheme.bodySmall);
    }

    if (notifier.isDownloading) {
      return Text(localizations.updateDownloading, style: textTheme.bodySmall);
    }

    if (notifier.isInstalling) {
      return Text(localizations.updateInstalling, style: textTheme.bodySmall);
    }

    if (notifier.error != null) {
      return Text(
        localizations.updateError,
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    if (notifier.updateAvailable) {
      return Text(
        localizations.updateAvailableDesc,
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Text(localizations.checkForUpdatesDesc, style: textTheme.bodySmall);
  }

  Widget? _buildUpdateTrailing(
    BuildContext context,
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
        onPressed: () => _handleStartUpdate(context, notifier),
        child: Text(localizations.updateNow),
      );
    }

    return const Icon(Icons.arrow_forward_ios, size: 16);
  }

  Future<void> _handleUpdateCheck(
    BuildContext context,
    UpdateNotifier notifier,
  ) async {
    await notifier.checkForUpdate();

    if (!context.mounted) return;

    if (notifier.error != null) {
      AppToast.show(
        context,
        localizations.updateError,
        type: ToastType.error,
      );
    } else if (!notifier.updateAvailable) {
      AppToast.show(
        context,
        localizations.noUpdateAvailable,
        type: ToastType.info,
      );
    }
  }

  Future<void> _handleStartUpdate(
    BuildContext context,
    UpdateNotifier notifier,
  ) async {
    // Start flexible update (allows background download)
    final success = await notifier.startFlexibleUpdate();

    if (!context.mounted) return;

    if (success) {
      AppToast.show(
        context,
        localizations.updateDownloading,
        type: ToastType.info,
        icon: Icons.download,
      );
    } else if (notifier.error != null) {
      AppToast.show(
        context,
        localizations.updateError,
        type: ToastType.error,
      );
    }
  }
}
