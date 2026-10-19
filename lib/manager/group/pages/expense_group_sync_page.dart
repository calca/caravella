import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../../sync/bluetooth_advertise_sheet.dart';
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
    final bt =
        BluetoothSyncFactory.isEnabled &&
        await BluetoothSyncFactory.isUserEnabled();

    if (mounted) {
      setState(() {
        _lanAvailable = lan;
        _btAvailable = bt;
        _checkingChannels = false;
      });
    }
  }

  // Sharing can only ever be truly active while a channel (Wi-Fi or
  // Bluetooth sync) is turned on app-wide — without one, a group's stored
  // `syncEnabled` flag is just a dormant preference, so the switch must
  // neither display nor be toggleable as if it were live.
  bool _canToggleSync(SyncOrchestrator? orchestrator, bool canToggleOn) =>
      orchestrator != null && canToggleOn;

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
    final channel = BluetoothSyncFactory.createChannel(orchestrator);
    if (channel == null) return;
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
      child: AppSystemUI.edgeToEdge(
        child: SettingsScaffold(
          eyebrow: _currentTrip.title,
          title: gloc.sync_title,
          description: gloc.sync_settings_desc,
          children: [
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.sync_outlined,
                  title: gloc.sync_group_enable,
                  subtitle: canToggleOn
                      ? gloc.sync_group_enable_desc
                      : gloc.sync_group_needs_channel,
                  switchValue: _currentTrip.syncEnabled && canToggleOn,
                  onSwitch: !_canToggleSync(orchestrator, canToggleOn)
                      ? null
                      : (value) => _handleSyncToggle(value),
                ),
              ],
            ),
            if (orchestrator != null &&
                _currentTrip.syncEnabled &&
                canToggleOn) ...[
              SettingsGroup(
                label: gloc.sync_paired_devices_title,
                children: [
                  if (_lanAvailable)
                    SettingsTile(
                      icon: Icons.qr_code,
                      title: gloc.sync_qr_show_button,
                      onTap: () => _showQr(context, orchestrator),
                    ),
                  if (_btAvailable)
                    SettingsTile(
                      icon: Icons.bluetooth,
                      title: gloc.sync_bt_title,
                      onTap: () => _shareViaBluetooth(context, orchestrator),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: PairedDevicesList(
                      orchestrator: orchestrator,
                      groupId: _currentTrip.id,
                      showRemoveAction: true,
                    ),
                  ),
                ],
              ),
            ],
            if (orchestrator != null)
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.history,
                    title: gloc.sync_history_title,
                    onTap: () => _openHistory(context, orchestrator),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
