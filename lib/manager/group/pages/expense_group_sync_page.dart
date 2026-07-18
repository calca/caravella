import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../../sync/bluetooth_advertise_sheet.dart';
import '../../../sync/bluetooth_sync_channel.dart';
import '../../../sync/bluetooth_sync_factory.dart';
import '../../../sync/qr_pair_show_sheet.dart';
import '../../../sync/sync_history_page.dart';
import '../../../sync/widgets/paired_devices_list.dart';

/// Per-group sync settings sub-page, reached from [GroupSettingsPage].
///
/// Sharing this group only takes effect once Wi-Fi or Bluetooth sync is
/// turned on app-wide (Settings → Sync) — this page shows why the "Share
/// this group" toggle is disabled otherwise, and once it's on, hosts the
/// actual QR code / Bluetooth advertising for whichever channel is
/// available, scoped to this group specifically.
class ExpenseGroupSyncPage extends StatefulWidget {
  final ExpenseGroup trip;

  const ExpenseGroupSyncPage({super.key, required this.trip});

  @override
  State<ExpenseGroupSyncPage> createState() => _ExpenseGroupSyncPageState();
}

class _ExpenseGroupSyncPageState extends State<ExpenseGroupSyncPage> {
  late ExpenseGroup _currentTrip;
  bool _changed = false;

  bool _lanAvailable = false;
  bool _btAvailable = false;
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
        _lanAvailable = lan;
        _btAvailable = bt;
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

  void _showQr(BuildContext context, SyncOrchestrator orchestrator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QrPairShowSheet(
        orchestrator: orchestrator,
        groupId: _currentTrip.id,
        groupTitle: _currentTrip.title,
      ),
    ).whenComplete(() => setState(() {}));
  }

  void _openHistory(BuildContext context, SyncOrchestrator orchestrator) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SyncHistoryPage(
          orchestrator: orchestrator,
          groupId: _currentTrip.id,
          groupTitle: _currentTrip.title,
        ),
      ),
    );
  }

  void _shareViaBluetooth(BuildContext context, SyncOrchestrator orchestrator) {
    final channel = BluetoothSyncChannel()
      ..onDelta = orchestrator.handleIncomingDelta
      ..onPairingRequest = orchestrator.handlePairingCompleted;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BluetoothAdvertiseSheet(
        channel: channel,
        groupId: _currentTrip.id,
        groupTitle: _currentTrip.title,
      ),
    ).whenComplete(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final orchestrator = context.watch<SyncOrchestrator?>();

    final channelsAvailable = _lanAvailable || _btAvailable;
    final canToggleOn =
        orchestrator != null && !_checkingChannels && channelsAvailable;

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
              ],
            ),
            if (orchestrator != null && _currentTrip.syncEnabled) ...[
              SettingsSection(
                title: gloc.sync_paired_devices_title,
                description: '',
                children: [
                  if (_lanAvailable) ...[
                    SettingsCard(
                      context: context,
                      color: colorScheme.surface,
                      semanticsButton: true,
                      semanticsLabel: gloc.sync_qr_show_button,
                      onTap: () => _showQr(context, orchestrator),
                      child: ListTile(
                        leading: Icon(Icons.qr_code, color: colorScheme.primary),
                        title: Text(
                          gloc.sync_qr_show_button,
                          style: textTheme.titleMedium,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_btAvailable) ...[
                    SettingsCard(
                      context: context,
                      color: colorScheme.surface,
                      semanticsButton: true,
                      semanticsLabel: gloc.sync_bt_title,
                      onTap: () => _shareViaBluetooth(context, orchestrator),
                      child: ListTile(
                        leading:
                            Icon(Icons.bluetooth, color: colorScheme.primary),
                        title: Text(
                          gloc.sync_bt_title,
                          style: textTheme.titleMedium,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SettingsCard(
                    context: context,
                    color: colorScheme.surface,
                    semanticsLabel: gloc.sync_paired_devices_title,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: PairedDevicesList(
                        orchestrator: orchestrator,
                        groupId: _currentTrip.id,
                        showRemoveAction: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (orchestrator != null) ...[
              SettingsSection(
                title: gloc.sync_history_title,
                description: '',
                children: [
                  SettingsCard(
                    context: context,
                    color: colorScheme.surface,
                    semanticsButton: true,
                    semanticsLabel: gloc.sync_history_title,
                    onTap: () => _openHistory(context, orchestrator),
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(
                        gloc.sync_history_title,
                        style: textTheme.titleMedium,
                      ),
                      trailing: const Icon(Icons.chevron_right),
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
