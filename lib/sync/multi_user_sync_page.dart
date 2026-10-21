import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_factory.dart';
import 'bluetooth_sync_sheet.dart';
import 'qr_pair_scan_page.dart';

/// Settings sub-page for syncing with **other people's** devices — Wi-Fi LAN
/// auto-discovery and manual Bluetooth pairing.
///
/// Contrast with [MultiDeviceSyncPage] (`multi_device_sync_page.dart`),
/// which syncs a single user's *own* devices via the optional Google Drive
/// relay — the two are separate pages because they solve different problems
/// (pairing with someone else vs. keeping your own devices in sync).
///
/// Only holds the two on/off toggles plus the group-agnostic "receiving"
/// actions (scan a code / discover a nearby device) — a device that hasn't
/// seen a shared group yet has nowhere else to start from. *Showing* a code
/// or *advertising* to share a specific group happens from that group's own
/// Sync sub-page instead (`ExpenseGroupSyncPage`), since pairing now grants
/// access to that one group, not every synced group.
class MultiUserSyncPage extends StatelessWidget {
  final SyncOrchestrator orchestrator;

  const MultiUserSyncPage({super.key, required this.orchestrator});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.sync_title,
        title: loc.sync_multiuser_title,
        description: loc.sync_multiuser_description,
        children: [
          _LocalSyncSection(orchestrator: orchestrator),
          // Hidden when built with --dart-define=ENABLE_BLUETOOTH_SYNC=false
          // (F-Droid-style builds that want to exclude the Google Play
          // Services dependency `nearby_connections` pulls in) — see
          // docs/FDROID_SUBMISSION.md.
          if (BluetoothSyncFactory.isEnabled)
            _BluetoothSyncSection(orchestrator: orchestrator),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Local sync section – Wi-Fi status + scan-a-code entry point
// ---------------------------------------------------------------------------

class _LocalSyncSection extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const _LocalSyncSection({required this.orchestrator});

  @override
  State<_LocalSyncSection> createState() => _LocalSyncSectionState();
}

class _LocalSyncSectionState extends State<_LocalSyncSection> {
  bool _enabled = false;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await widget.orchestrator.isLanSyncEnabled();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleLan(bool value) async {
    setState(() => _busy = true);
    await widget.orchestrator.setLanSyncEnabled(value);
    if (mounted) {
      setState(() {
        _enabled = value;
        _busy = false;
      });
    }
    LoggerService.info(
      'Local sync ${value ? 'enabled' : 'disabled'} by user',
      name: 'settings',
    );
  }

  Future<void> _scanQr(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => QrPairScanPage(orchestrator: widget.orchestrator),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return SettingsGroup(
      label: loc.sync_local_title,
      children: [
        SettingsTile(
          icon: _enabled ? Icons.wifi : Icons.wifi_off,
          title: loc.sync_local_title,
          subtitle: loc.sync_local_description,
          switchValue: _enabled,
          onSwitch: _loading || _busy ? null : _toggleLan,
          trailing: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        if (_enabled && GmsIntegrations.instance.supportsQrScanning)
          SettingsTile(
            icon: Icons.qr_code_scanner,
            title: loc.sync_qr_scan_button,
            subtitle: loc.sync_qr_scan_description,
            onTap: () => _scanQr(context),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bluetooth sync section – enable toggle + discover-a-device entry point
// ---------------------------------------------------------------------------

class _BluetoothSyncSection extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const _BluetoothSyncSection({required this.orchestrator});

  @override
  State<_BluetoothSyncSection> createState() => _BluetoothSyncSectionState();
}

class _BluetoothSyncSectionState extends State<_BluetoothSyncSection> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await BluetoothSyncFactory.isUserEnabled();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    await BluetoothSyncFactory.setUserEnabled(value);
    if (mounted) {
      setState(() => _enabled = value);
    }
    LoggerService.info(
      'Bluetooth sync ${value ? 'enabled' : 'disabled'} by user',
      name: 'settings',
    );
  }

  void _discoverDevices(BuildContext context) {
    final channel = BluetoothSyncFactory.createChannel(widget.orchestrator);
    if (channel == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BluetoothSyncSheet(channel: channel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return SettingsGroup(
      label: loc.sync_channel_bluetooth,
      children: [
        SettingsTile(
          icon: _enabled ? Icons.bluetooth : Icons.bluetooth_disabled,
          title: loc.sync_bt_title,
          subtitle: loc.sync_bt_description,
          switchValue: _enabled,
          onSwitch: _loading ? null : _toggle,
        ),
        if (_enabled)
          SettingsTile(
            icon: Icons.bluetooth_searching,
            title: loc.sync_bt_title,
            onTap: () => _discoverDevices(context),
          ),
      ],
    );
  }
}
