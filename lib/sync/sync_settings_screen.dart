import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_factory.dart';
import 'multi_device_sync_page.dart';
import 'multi_user_sync_page.dart';
import 'sync_history_page.dart';
import 'sync_problem_tile.dart';

/// Entry point for Settings → Sync.
///
/// Routes to the two sync sub-pages — [MultiUserSyncPage] (Wi-Fi/Bluetooth
/// pairing with other people's devices) and [MultiDeviceSyncPage] (cloud
/// sync across a single user's own devices) — plus the shared sync history,
/// which spans all channels.
///
/// Also where Home's sync button leads: when something is still wrong
/// ([SyncOrchestrator.problems], the ochre dot), a "To fix" group on top
/// says which group and device, why, and what to do; tapping a row opens
/// the page to fix it on.
class SyncSettingsScreen extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const SyncSettingsScreen({super.key, required this.orchestrator});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  SyncOrchestrator get orchestrator => widget.orchestrator;
  StreamSubscription<SyncEvent>? _events;
  List<SyncProblem> _problems = const [];
  SyncNames _names = const SyncNames();

  /// Whether there's anything in the history yet: until then its row is
  /// greyed out, saying so.
  bool? _hasHistory;

  @override
  void initState() {
    super.initState();
    _refresh();
    _events = orchestrator.events.listen((_) => _refresh());
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final problems = orchestrator.problems;
    final names = await SyncNames.load(
      orchestrator,
      problems.map((p) => p.groupId).whereType<String>(),
    );
    final history = await orchestrator.getHistory(limit: 1);
    if (!mounted) return;
    setState(() {
      _problems = problems;
      _names = names;
      _hasHistory = history.isNotEmpty;
    });
  }

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
          if (_problems.isNotEmpty)
            SettingsGroup(
              label: loc.sync_to_fix_title,
              children: [
                for (final p in _problems)
                  SyncProblemTile(
                    problem: p,
                    names: _names,
                    // Where it gets fixed: Drive's page for the cloud,
                    // the pairing page for everything with a device.
                    onTap: p.reason == SyncProblemReason.cloudUnreachable
                        ? (orchestrator.isCloudEnabled
                              ? () => push(
                                  MultiDeviceSyncPage(
                                    orchestrator: orchestrator,
                                  ),
                                )
                              : null)
                        : () => push(
                            MultiUserSyncPage(orchestrator: orchestrator),
                          ),
                  ),
              ],
            ),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.group_outlined,
                title: loc.sync_multiuser_title,
                subtitle: BluetoothSyncFactory.isEnabled
                    ? loc.sync_multiuser_description
                    : loc.sync_multiuser_description_wifi,
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
                subtitle: _hasHistory == false ? loc.sync_history_empty : null,
                enabled: _hasHistory ?? false,
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
