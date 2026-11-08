import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_factory.dart';
import 'join_group_page.dart';

/// Settings sub-page for syncing with **other people's** devices: "Join a
/// group" ([JoinGroupPage]: a QR code on the same Wi-Fi, or a nearby phone
/// over Bluetooth) and the two privacy switches saying what Caravella may
/// use: Wi-Fi (automatic sync on the same network) and Bluetooth (only
/// while "Join a group" or an invite is open). With both off this phone is
/// invisible to others and receives nothing.
///
/// Contrast with [MultiDeviceSyncPage] (`multi_device_sync_page.dart`),
/// which syncs a single user's *own* devices via the optional Google Drive
/// relay.
///
/// Only the receiving side lives here, since a device that hasn't been
/// given a group yet has nowhere else to start from. *Inviting* to a group
/// happens from that group's own Sync sub-page (`ExpenseGroupSyncPage`),
/// since pairing grants access to that one group. The Bluetooth switch is
/// missing from builds without Bluetooth (F-Droid,
/// `ENABLE_BLUETOOTH_SYNC=false`).
class MultiUserSyncPage extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const MultiUserSyncPage({super.key, required this.orchestrator});

  @override
  State<MultiUserSyncPage> createState() => _MultiUserSyncPageState();
}

class _MultiUserSyncPageState extends State<MultiUserSyncPage> {
  bool _wifi = false;
  bool _loading = true;
  bool _busy = false;
  bool _btOn = false;

  bool get _bluetooth => BluetoothSyncFactory.isEnabled;

  /// Joining needs one of the two: the camera for a QR code, or Bluetooth.
  bool get _canJoin =>
      GmsIntegrations.instance.supportsQrScanning || _bluetooth;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final wifi = await widget.orchestrator.isLanSyncEnabled();
    final bt = await BluetoothSyncFactory.isUserEnabled();
    if (mounted) {
      setState(() {
        _wifi = wifi;
        _btOn = bt;
        _loading = false;
      });
    }
  }

  Future<void> _setBluetooth(bool value) async {
    await BluetoothSyncFactory.setUserEnabled(value);
    if (mounted) setState(() => _btOn = value);
  }

  Future<void> _setWifi(bool value) async {
    setState(() => _busy = true);
    await widget.orchestrator.setLanSyncEnabled(value);
    if (mounted) {
      setState(() {
        _wifi = value;
        _busy = false;
      });
    }
    LoggerService.info(
      'Local sync ${value ? 'enabled' : 'disabled'} by user',
      name: 'settings',
    );
  }

  Future<void> _join() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => JoinGroupPage(
          orchestrator: widget.orchestrator,
          wifiEnabled: _wifi,
          onTurnOnWifi: () => _setWifi(true),
          bluetooth: BluetoothSyncFactory.createChannel(widget.orchestrator),
          bluetoothEnabled: _btOn,
          onTurnOnBluetooth: () => _setBluetooth(true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.sync_title,
        title: loc.sync_multiuser_title,
        description: loc.sync_multiuser_description,
        children: [
          if (_canJoin)
            SettingsGroup(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _loading ? null : _join,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(loc.sync_join_button),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _bluetooth
                            ? loc.sync_join_button_desc
                            : loc.sync_qr_scan_description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          SettingsGroup(
            label: loc.sync_privacy_section,
            children: [
              SettingsTile(
                icon: _wifi ? Icons.wifi : Icons.wifi_off,
                title: loc.sync_local_title,
                subtitle: loc.sync_wifi_switch_desc,
                switchValue: _wifi,
                onSwitch: _loading || _busy ? null : _setWifi,
                trailing: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              if (_bluetooth)
                SettingsTile(
                  icon: _btOn ? Icons.bluetooth : Icons.bluetooth_disabled,
                  title: loc.sync_channel_bluetooth,
                  subtitle: loc.sync_bt_switch_desc,
                  switchValue: _btOn,
                  onSwitch: _loading ? null : _setBluetooth,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              loc.sync_privacy_footer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
