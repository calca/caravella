import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../settings/widgets/settings_card.dart';
import 'update_service_factory.dart';
import 'update_service_interface.dart';

/// Widget for displaying update check functionality in settings.
/// 
/// This widget handles all the update-related UI logic including:
/// - Checking for updates
/// - Displaying update status
/// - Starting update downloads
/// - Platform detection
class UpdateCheckWidget extends StatelessWidget {
  const UpdateCheckWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Only show on Android
    if (!Platform.isAndroid) {
      return SettingsCard(
        context: context,
        color: colorScheme.surface,
        child: ListTile(
          leading: const Icon(Icons.system_update_outlined),
          title: Text(loc.check_for_updates, style: textTheme.titleMedium),
          subtitle: Text(loc.update_feature_android_only, style: textTheme.bodySmall),
          enabled: false,
        ),
      );
    }

    return ChangeNotifierProvider<UpdateNotifier>(
      create: (_) => UpdateServiceFactory.createUpdateNotifier(),
      child: Consumer<UpdateNotifier>(
        builder: (context, notifier, _) {
          return SettingsCard(
            context: context,
            color: colorScheme.surface,
            child: ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: Text(loc.check_for_updates, style: textTheme.titleMedium),
              subtitle: _buildUpdateSubtitle(context, loc, notifier),
              trailing: _buildUpdateTrailing(context, loc, notifier),
              onTap: notifier.isChecking || notifier.isDownloading || notifier.isInstalling
                  ? null
                  : () => _handleUpdateCheck(context, loc, notifier),
            ),
          );
        },
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
      return Text(loc.update_error, style: textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ));
    }
    
    if (notifier.updateAvailable) {
      return Text(loc.update_available_desc, style: textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ));
    }
    
    return Text(loc.check_for_updates_desc, style: textTheme.bodySmall);
  }

  Widget? _buildUpdateTrailing(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
  ) {
    if (notifier.isChecking || notifier.isDownloading || notifier.isInstalling) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.update_error)),
      );
    } else if (!notifier.updateAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.no_update_available)),
      );
    }
  }

  Future<void> _handleStartUpdate(
    BuildContext context,
    gen.AppLocalizations loc,
    UpdateNotifier notifier,
  ) async {
    // Show dialog to choose update type
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.update_available),
        content: Text(loc.update_available_desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.update_later),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.update_now),
          ),
        ],
      ),
    );
    
    if (result != true || !context.mounted) return;
    
    // Start flexible update (allows background download)
    final success = await notifier.startFlexibleUpdate();
    
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.update_downloading)),
      );
    } else if (notifier.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.update_error)),
      );
    }
  }
}
