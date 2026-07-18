import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'multi_device_sync_page.dart';
import 'multi_user_sync_page.dart';
import 'sync_history_sheet.dart';

/// Entry point for Settings → Sync.
///
/// Routes to the two sync sub-pages — [MultiUserSyncPage] (Wi-Fi/Bluetooth
/// pairing with other people's devices) and [MultiDeviceSyncPage] (cloud
/// sync across a single user's own devices) — plus the shared sync history,
/// which spans all channels.
class SyncSettingsScreen extends StatelessWidget {
  final SyncOrchestrator orchestrator;

  const SyncSettingsScreen({super.key, required this.orchestrator});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return AppSystemUI.surface(
      child: Scaffold(
        appBar: const CaravellaAppBar(),
        body: ListView(
          children: [
            SettingsSection(
              title: loc.sync_title,
              description: loc.sync_settings_desc,
              children: [
                _buildMultiUserTile(context, loc),
                // Only built into the app when compiled with
                // --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true — see
                // docs/GOOGLE_DRIVE_SYNC_SETUP.md.
                if (orchestrator.isCloudEnabled) ...[
                  const SizedBox(height: 8),
                  _buildMultiDeviceTile(context, loc),
                ],
              ],
            ),
            _buildHistorySection(context, loc),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Entry tiles
  // ---------------------------------------------------------------------------

  Widget _buildMultiUserTile(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      semanticsButton: true,
      semanticsLabel: loc.sync_multiuser_title,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiUserSyncPage(orchestrator: orchestrator),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.group_outlined, color: colorScheme.primary),
        title: Text(loc.sync_multiuser_title, style: textTheme.titleMedium),
        subtitle: Text(loc.sync_multiuser_description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildMultiDeviceTile(
    BuildContext context,
    gen.AppLocalizations loc,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      semanticsButton: true,
      semanticsLabel: loc.sync_multidevice_title,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiDeviceSyncPage(orchestrator: orchestrator),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.devices_outlined, color: colorScheme.primary),
        title: Text(loc.sync_multidevice_title, style: textTheme.titleMedium),
        subtitle: Text(loc.sync_multidevice_description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // History section
  // ---------------------------------------------------------------------------

  Widget _buildHistorySection(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSection(
      title: loc.sync_history_title,
      description: '',
      children: [
        SettingsCard(
          context: context,
          color: colorScheme.surface,
          semanticsButton: true,
          semanticsLabel: loc.sync_history_title,
          onTap: () => _openHistory(context),
          child: ListTile(
            leading: const Icon(Icons.history),
            title:
                Text(loc.sync_history_title, style: textTheme.titleMedium),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  void _openHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SyncHistorySheet(orchestrator: orchestrator),
    );
  }
}
