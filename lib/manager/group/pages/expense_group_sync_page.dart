import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../../settings/widgets/settings_section.dart';
import '../../../settings/widgets/settings_card.dart';
import '../../../sync/bluetooth_sync_factory.dart';
import '../../../sync/multi_user_sync_page.dart';
import '../../../sync/widgets/paired_devices_list.dart';

/// Per-group sync settings sub-page, reached from [GroupSettingsPage].
///
/// Enabling sync for a group only takes effect once Wi-Fi or Bluetooth sync
/// is turned on app-wide (Settings → Sync → [MultiUserSyncPage]) — pairing
/// itself always happens there, not on this page.
class ExpenseGroupSyncPage extends StatefulWidget {
  final ExpenseGroup trip;

  const ExpenseGroupSyncPage({super.key, required this.trip});

  @override
  State<ExpenseGroupSyncPage> createState() => _ExpenseGroupSyncPageState();
}

class _ExpenseGroupSyncPageState extends State<ExpenseGroupSyncPage> {
  late ExpenseGroup _currentTrip;
  bool _changed = false;

  bool _channelsAvailable = false;
  bool _checkingChannels = true;
  SyncOrchestrator? _lastCheckedOrchestrator;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orchestrator = Provider.of<SyncOrchestrator?>(context, listen: false);
    _ensureChannelsChecked(orchestrator);
  }

  Future<void> _ensureChannelsChecked(SyncOrchestrator? orchestrator) async {
    if (orchestrator == null ||
        identical(orchestrator, _lastCheckedOrchestrator)) {
      return;
    }
    _lastCheckedOrchestrator = orchestrator;

    final lan = await orchestrator.isLanSyncEnabled();
    final bt = BluetoothSyncFactory.isEnabled &&
        await BluetoothSyncFactory.isUserEnabled();

    if (mounted) {
      setState(() {
        _channelsAvailable = lan || bt;
        _checkingChannels = false;
      });
    }
  }

  Future<void> _handleSyncToggle(bool enabled) async {
    final groupNotifier = Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    );
    await groupNotifier.updateGroupMetadata(
      _currentTrip.copyWith(syncEnabled: enabled),
    );

    if (!mounted) return;

    setState(() {
      _currentTrip = _currentTrip.copyWith(syncEnabled: enabled);
      _changed = true;
    });
  }

  Future<void> _openDevicePairing(
    BuildContext context,
    SyncOrchestrator orchestrator,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiUserSyncPage(orchestrator: orchestrator),
      ),
    );
    // Wi-Fi/Bluetooth sync may have been turned on (or off) while the user
    // was in Settings — refresh so the toggle above reflects it immediately.
    _lastCheckedOrchestrator = null;
    await _ensureChannelsChecked(orchestrator);
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final orchestrator = context.watch<SyncOrchestrator?>();

    final canToggleOn =
        orchestrator != null && !_checkingChannels && _channelsAvailable;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: CaravellaAppBar(actions: const []),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            SettingsSection(
              title: gloc.sync_title,
              description: gloc.sync_settings_desc,
              children: [
                SettingsCard(
                  context: context,
                  color: colorScheme.surface,
                  semanticsToggled: _currentTrip.syncEnabled,
                  child: SwitchListTile(
                    secondary: const Icon(Icons.sync_outlined),
                    title: Text(
                      gloc.sync_group_enable,
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      canToggleOn || _currentTrip.syncEnabled
                          ? gloc.sync_group_enable_desc
                          : gloc.sync_group_needs_channel,
                      style: textTheme.bodySmall,
                    ),
                    value: _currentTrip.syncEnabled,
                    onChanged: orchestrator == null ||
                            (!canToggleOn && !_currentTrip.syncEnabled)
                        ? null
                        : (value) => _handleSyncToggle(value),
                  ),
                ),
                if (orchestrator != null) ...[
                  const SizedBox(height: 8),
                  SettingsCard(
                    context: context,
                    color: colorScheme.surface,
                    semanticsButton: true,
                    semanticsLabel: gloc.sync_group_manage_pairing_title,
                    child: ListTile(
                      leading: Icon(
                        Icons.devices_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        gloc.sync_group_manage_pairing_title,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(gloc.sync_group_manage_pairing_desc),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openDevicePairing(context, orchestrator),
                    ),
                  ),
                ],
              ],
            ),
            if (orchestrator != null && _currentTrip.syncEnabled) ...[
              SettingsSection(
                title: gloc.sync_paired_devices_title,
                description: '',
                children: [
                  SettingsCard(
                    context: context,
                    color: colorScheme.surface,
                    semanticsLabel: gloc.sync_paired_devices_title,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: PairedDevicesList(orchestrator: orchestrator),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
