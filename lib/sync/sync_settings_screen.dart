import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_drive_sync/google_drive_sync.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../settings/widgets/settings_card.dart';
import '../settings/widgets/settings_section.dart';
import 'bluetooth_sync_channel.dart';
import 'bluetooth_sync_factory.dart';
import 'bluetooth_sync_sheet.dart';
import 'qr_pair_scan_page.dart';
import 'qr_pair_show_sheet.dart';
import 'sync_history_sheet.dart';
import 'widgets/paired_devices_list.dart';

/// Full settings page for sync configuration.
///
/// Follows the existing settings pattern with [CaravellaAppBar],
/// [SettingsSection], and [SettingsCard] widgets.
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
            _buildLocalSection(context, loc),
            // Hidden when built with --dart-define=ENABLE_BLUETOOTH_SYNC=false
            // (F-Droid-style builds that want to exclude the Google Play
            // Services dependency `nearby_connections` pulls in) — see
            // docs/FDROID_SUBMISSION.md.
            if (BluetoothSyncFactory.isEnabled)
              _buildBluetoothSection(context, loc),
            // Only built into the app when compiled with
            // --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true — see
            // docs/GOOGLE_DRIVE_SYNC_SETUP.md.
            if (orchestrator.isCloudEnabled) _buildCloudSection(context, loc),
            _buildHistorySection(context, loc),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Local Sync section
  // ---------------------------------------------------------------------------

  Widget _buildLocalSection(BuildContext context, gen.AppLocalizations loc) {
    return _LocalSyncSection(orchestrator: orchestrator);
  }

  // ---------------------------------------------------------------------------
  // Bluetooth pairing section
  // ---------------------------------------------------------------------------

  Widget _buildBluetoothSection(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsSection(
      title: loc.sync_channel_bluetooth,
      description: loc.sync_bt_searching,
      children: [
        SettingsCard(
          context: context,
          semanticsButton: true,
          semanticsLabel: loc.sync_bt_title,
          child: ListTile(
            leading: Icon(Icons.bluetooth, color: colorScheme.primary),
            title: Text(loc.sync_bt_title, style: textTheme.titleMedium),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openBluetoothPairing(context),
          ),
        ),
      ],
    );
  }

  void _openBluetoothPairing(BuildContext context) {
    final channel = BluetoothSyncChannel()
      ..onDelta = orchestrator.handleIncomingDelta;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BluetoothSyncSheet(channel: channel),
    );
  }

  // ---------------------------------------------------------------------------
  // Cloud Sync section
  // ---------------------------------------------------------------------------

  Widget _buildCloudSection(BuildContext context, gen.AppLocalizations loc) {
    return SettingsSection(
      title: loc.sync_cloud_title,
      description: loc.sync_cloud_description,
      children: [
        _CloudSyncCard(orchestrator: orchestrator),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // History section
  // ---------------------------------------------------------------------------

  Widget _buildHistorySection(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;

    return SettingsSection(
      title: loc.sync_history_title,
      description: '',
      children: [
        SettingsCard(
          context: context,
          semanticsButton: true,
          semanticsLabel: loc.sync_history_title,
          child: ListTile(
            leading: const Icon(Icons.history),
            title:
                Text(loc.sync_history_title, style: textTheme.titleMedium),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openHistory(context),
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

// ---------------------------------------------------------------------------
// Cloud sync card – StatefulWidget for toggle + privacy dialog + sync now
// ---------------------------------------------------------------------------

class _CloudSyncCard extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const _CloudSyncCard({required this.orchestrator});

  @override
  State<_CloudSyncCard> createState() => _CloudSyncCardState();
}

class _CloudSyncCardState extends State<_CloudSyncCard> {
  bool _enabled = false;
  bool _loading = true;
  bool _busy = false;
  DateTime? _lastCloudSync;

  // The orchestrator owns the real channel instance — reusing it (rather
  // than constructing a new one) is what keeps the Google sign-in session
  // alive across rebuilds.
  CloudRelayChannel? get _cloudChannel => widget.orchestrator.cloudChannel;

  GoogleDriveCloudChannel? get _driveChannel {
    final channel = _cloudChannel;
    return channel is GoogleDriveCloudChannel ? channel : null;
  }

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final cloud = _cloudChannel;
    if (cloud == null) {
      setState(() => _loading = false);
      return;
    }
    final enabled = await cloud.isEnabled();
    if (enabled) {
      // Restore a prior Google sign-in session so the linked account shows
      // up without forcing the user to sign in again every app launch.
      await _driveChannel?.restoreSession();
    }
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleCloud(bool value) async {
    final loc = gen.AppLocalizations.of(context);

    if (value && !_enabled) {
      final confirmed = await _showPrivacyDialog();
      if (confirmed != true) return;

      final drive = _driveChannel;
      if (drive != null) {
        setState(() => _busy = true);
        final signedIn = await drive.signIn();
        if (mounted) setState(() => _busy = false);
        if (!signedIn) {
          if (mounted) {
            AppToast.show(
              context,
              loc.sync_cloud_sign_in_failed,
              type: ToastType.error,
            );
          }
          return;
        }
      }
    }

    final cloud = _cloudChannel;
    if (cloud == null) return;

    await cloud.setEnabled(value);
    if (!value) {
      await _driveChannel?.signOut();
    }

    if (mounted) {
      setState(() => _enabled = value);
    }

    if (value) {
      LoggerService.info('Cloud sync enabled by user', name: 'settings');
    } else {
      LoggerService.info('Cloud sync disabled by user', name: 'settings');
    }
  }

  Future<bool?> _showPrivacyDialog() {
    final loc = gen.AppLocalizations.of(context);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.sync_cloud_title),
        content: Text(loc.sync_cloud_privacy),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.sync_cloud_enable),
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow() async {
    LoggerService.info('Manual cloud sync triggered', name: 'settings');
    final result = await widget.orchestrator.triggerManualSync('cloud');
    if (mounted) {
      setState(() {
        _lastCloudSync = result.syncedAt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enable / disable toggle
        SettingsCard(
          context: context,
          semanticsLabel: loc.sync_cloud_enable,
          semanticsToggled: _enabled,
          child: SwitchListTile(
            secondary: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.cloud_outlined, color: colorScheme.primary),
            title: Text(loc.sync_cloud_enable, style: textTheme.titleMedium),
            subtitle: Text(
              _enabled && _driveChannel?.signedInAccountEmail != null
                  ? loc.sync_cloud_signed_in_as(
                      _driveChannel!.signedInAccountEmail!,
                    )
                  : loc.sync_cloud_description,
            ),
            value: _enabled,
            onChanged: _busy ? null : _toggleCloud,
          ),
        ),
        // Sync now button – visible only when cloud is enabled
        if (_enabled) ...[
          const SizedBox(height: 8),
          SettingsCard(
            context: context,
            semanticsButton: true,
            semanticsLabel: loc.sync_now,
            child: ListTile(
              leading: Icon(Icons.sync, color: colorScheme.primary),
              title: Text(loc.sync_now, style: textTheme.titleMedium),
              subtitle: _lastCloudSync != null
                  ? Text(loc.sync_last_sync(_formatTime(_lastCloudSync!)))
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _syncNow,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().toUtc().difference(dt);
    if (diff.inSeconds < 60) return '<1 min';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ---------------------------------------------------------------------------
// Local sync section – Wi-Fi status, QR pairing, paired devices list
// ---------------------------------------------------------------------------

class _LocalSyncSection extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const _LocalSyncSection({required this.orchestrator});

  @override
  State<_LocalSyncSection> createState() => _LocalSyncSectionState();
}

class _LocalSyncSectionState extends State<_LocalSyncSection> {
  // Bumped after a successful QR pairing to force PairedDevicesList to
  // reload via a new key.
  int _refreshTick = 0;

  void _showQr(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QrPairShowSheet(orchestrator: widget.orchestrator),
    );
  }

  Future<void> _scanQr(BuildContext context) async {
    final paired = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => QrPairScanPage(orchestrator: widget.orchestrator),
      ),
    );
    if (paired == true && mounted) {
      setState(() => _refreshTick++);
    }
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
          semanticsLabel: loc.sync_local_title,
          child: ListTile(
            leading: Icon(Icons.wifi, color: colorScheme.primary),
            title: Text(loc.sync_local_title, style: textTheme.titleMedium),
            subtitle: Text(loc.sync_local_description),
            trailing: Icon(
              widget.orchestrator.isLanActive
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: widget.orchestrator.isLanActive
                  ? colorScheme.primary
                  : colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SettingsCard(
          context: context,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showQr(context),
                    icon: const Icon(Icons.qr_code),
                    label: Text(loc.sync_qr_show_button),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _scanQr(context),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(loc.sync_qr_scan_button),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SettingsCard(
          context: context,
          semanticsLabel: loc.sync_paired_devices_title,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.sync_paired_devices_title, style: textTheme.labelLarge),
                const SizedBox(height: 4),
                PairedDevicesList(
                  key: ValueKey(_refreshTick),
                  orchestrator: widget.orchestrator,
                  showRemoveAction: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
