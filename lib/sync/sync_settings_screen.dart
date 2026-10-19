import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'multi_device_sync_page.dart';
import 'multi_user_sync_page.dart';
import 'sync_history_page.dart';

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
    void push(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.settings,
        title: loc.sync_title,
        children: [
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.group_outlined,
                title: loc.sync_multiuser_title,
                subtitle: loc.sync_multiuser_description,
                onTap: () =>
                    push(MultiUserSyncPage(orchestrator: orchestrator)),
              ),
              // Only built into the app when compiled with
              // --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true — see
              // docs/GOOGLE_DRIVE_SYNC_SETUP.md.
              if (orchestrator.isCloudEnabled)
                SettingsTile(
                  icon: Icons.devices_outlined,
                  title: loc.sync_multidevice_title,
                  subtitle: loc.sync_multidevice_description,
                  onTap: () =>
                      push(MultiDeviceSyncPage(orchestrator: orchestrator)),
                ),
            ],
          ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.history,
                title: loc.sync_history_title,
                onTap: () => _openHistory(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SyncHistoryPage(orchestrator: orchestrator),
      ),
    );
  }
}
