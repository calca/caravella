import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../settings/widgets/settings_card.dart';
import '../settings/widgets/settings_section.dart';
import 'sync_history_sheet.dart';

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
            _buildCloudSection(context, loc),
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
              orchestrator.isLanActive
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: orchestrator.isLanActive
                  ? colorScheme.primary
                  : colorScheme.outline,
            ),
          ),
        ),
      ],
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
  DateTime? _lastCloudSync;

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
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  CloudRelayChannel? get _cloudChannel {
    // The orchestrator exposes isCloudEnabled but not the channel directly.
    // We check availability via the public API.
    return widget.orchestrator.isCloudEnabled ? CloudRelayChannel() : null;
  }

  Future<void> _toggleCloud(bool value) async {
    if (value && !_enabled) {
      final confirmed = await _showPrivacyDialog();
      if (confirmed != true) return;
    }

    final cloud = _cloudChannel;
    if (cloud == null) return;

    await cloud.setEnabled(value);
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
            secondary: Icon(Icons.cloud_outlined, color: colorScheme.primary),
            title: Text(loc.sync_cloud_enable, style: textTheme.titleMedium),
            subtitle: Text(loc.sync_cloud_description),
            value: _enabled,
            onChanged: _toggleCloud,
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
