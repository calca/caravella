import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Settings sub-page for syncing a single user's **own** devices via the
/// optional Google Drive relay (`ENABLE_GOOGLE_DRIVE_SYNC`).
///
/// Contrast with [MultiUserSyncPage] (`multi_user_sync_page.dart`), which
/// pairs with *other people's* devices over Wi-Fi/Bluetooth — cloud sync
/// only ever reads/writes the signed-in Google account's own private
/// `appDataFolder`, so it has no equivalent pairing/trust step.
class MultiDeviceSyncPage extends StatelessWidget {
  final SyncOrchestrator orchestrator;

  const MultiDeviceSyncPage({super.key, required this.orchestrator});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.sync_title,
        title: loc.sync_cloud_title,
        description:
            '${loc.sync_cloud_description}. ${loc.sync_cloud_scope_description}',
        children: [_CloudSyncCard(orchestrator: orchestrator)],
      ),
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

  /// The account side of the channel (Google Drive sign-in), if it has one.
  CloudAccountChannel? get _driveChannel {
    final channel = _cloudChannel;
    return channel is CloudAccountChannel
        ? channel as CloudAccountChannel
        : null;
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

    return Material3Dialogs.showConfirmation(
      context,
      title: loc.sync_cloud_title,
      content: loc.sync_cloud_privacy,
      confirmText: loc.sync_cloud_enable,
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

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final email = _driveChannel?.signedInAccountEmail;
    return SettingsGroup(
      children: [
        SettingsTile(
          icon: Icons.cloud_outlined,
          title: loc.sync_cloud_enable,
          subtitle: _enabled && email != null
              ? loc.sync_cloud_signed_in_as(email)
              : loc.sync_cloud_description,
          switchValue: _enabled,
          onSwitch: _busy ? null : _toggleCloud,
          trailing: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        // Sync now – only when cloud sync is on
        if (_enabled)
          SettingsTile(
            icon: Icons.sync,
            title: loc.sync_now,
            subtitle: _lastCloudSync != null
                ? loc.sync_last_sync(_formatTime(_lastCloudSync!))
                : null,
            onTap: _syncNow,
          ),
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
