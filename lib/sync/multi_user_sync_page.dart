import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_channel.dart';
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
    return AppSystemUI.surface(
      child: Scaffold(
        appBar: const CaravellaAppBar(),
        body: ListView(
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
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsSection(
      title: loc.sync_local_title,
      description: loc.sync_local_description,
      children: [
        SettingsCard(
          context: context,
          color: colorScheme.surface,
          semanticsLabel: loc.sync_local_title,
          semanticsToggled: _enabled,
          onTap:
              _loading || _busy ? null : () => _toggleLan(!_enabled),
          child: ListTile(
            enabled: !_loading && !_busy,
            leading: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _enabled ? Icons.wifi : Icons.wifi_off,
                    color: _enabled ? colorScheme.primary : colorScheme.outline,
                  ),
            title: Text(loc.sync_local_title, style: textTheme.titleMedium),
            subtitle: Text(loc.sync_local_description),
            trailing: Switch(
              value: _enabled,
              onChanged: _loading || _busy ? null : _toggleLan,
            ),
          ),
        ),
        if (_enabled) ...[
          const SizedBox(height: 8),
          SettingsCard(
            context: context,
            color: colorScheme.surface,
            semanticsButton: true,
            semanticsLabel: loc.sync_qr_scan_button,
            onTap: () => _scanQr(context),
            child: ListTile(
              leading: Icon(Icons.qr_code_scanner, color: colorScheme.primary),
              title: Text(loc.sync_qr_scan_button, style: textTheme.titleMedium),
              subtitle: Text(loc.sync_qr_scan_description),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
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
    final channel = BluetoothSyncChannel()
      ..onDelta = widget.orchestrator.handleIncomingDelta
      ..onPairingRequest = widget.orchestrator.handlePairingCompleted;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BluetoothSyncSheet(channel: channel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsSection(
      title: loc.sync_channel_bluetooth,
      description: loc.sync_bt_description,
      children: [
        SettingsCard(
          context: context,
          color: colorScheme.surface,
          semanticsLabel: loc.sync_bt_title,
          semanticsToggled: _enabled,
          onTap: _loading ? null : () => _toggle(!_enabled),
          child: ListTile(
            enabled: !_loading,
            leading: Icon(
              _enabled ? Icons.bluetooth : Icons.bluetooth_disabled,
              color: _enabled ? colorScheme.primary : colorScheme.outline,
            ),
            title: Text(loc.sync_bt_title, style: textTheme.titleMedium),
            subtitle: Text(loc.sync_bt_description),
            trailing: Switch(
              value: _enabled,
              onChanged: _loading ? null : _toggle,
            ),
          ),
        ),
        if (_enabled) ...[
          const SizedBox(height: 8),
          SettingsCard(
            context: context,
            color: colorScheme.surface,
            semanticsButton: true,
            semanticsLabel: loc.sync_bt_title,
            onTap: () => _discoverDevices(context),
            child: ListTile(
              leading: Icon(Icons.bluetooth, color: colorScheme.primary),
              title: Text(loc.sync_bt_title, style: textTheme.titleMedium),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ],
    );
  }
}
