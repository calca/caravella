import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../pages/developer_page.dart';
import '../pages/whats_new_page.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// "Info" settings section: app info, version/changelog, and (in debug
/// builds, or when enabled via the `ENABLE_TALKER_SCREEN` dart-define) the
/// debug logs screen.
class InfoSettingsSection extends StatelessWidget {
  const InfoSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    // Show debug logs in debug mode or if build flag is enabled
    final showDebugLogs = kDebugMode || AppConfig.enableTalkerScreen;

    return SettingsSection(
      title: loc.settings_info,
      description: loc.settings_info_desc,
      children: [
        _buildInviteFriendsRow(context, loc),
        const SizedBox(height: 8),
        _buildInfoCardRow(context, loc),
        const SizedBox(height: 8),
        _buildAppVersionRow(context, loc),
        if (showDebugLogs) ...[
          const SizedBox(height: 8),
          _buildDebugLogsRow(context, loc),
        ],
      ],
    );
  }

  Widget _buildInviteFriendsRow(
    BuildContext context,
    gen.AppLocalizations loc,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.share_outlined),
        title: Text(loc.settings_invite_friends, style: textTheme.titleMedium),
        subtitle: Text(
          loc.settings_invite_friends_desc,
          style: textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _shareInvite(context, loc),
      ),
    );
  }

  Future<void> _shareInvite(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: loc.invite_friends_message),
      );
    } catch (e) {
      LoggerService.warning('Error sharing invite', name: 'ui.share');
    }
  }

  Widget _buildAppVersionRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(loc.settings_app_version, style: textTheme.titleMedium),
        subtitle: FutureBuilder<String>(
          future: _getAppVersion(),
          builder: (context, snapshot) => Text(snapshot.data ?? '-'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const WhatsNewPage())),
      ),
    );
  }

  Widget _buildInfoCardRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(loc.settings_info_card, style: textTheme.titleMedium),
        subtitle: Text(loc.settings_info_card_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const DeveloperPage())),
      ),
    );
  }

  Widget _buildDebugLogsRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.bug_report),
        title: Text('Debug Logs', style: textTheme.titleMedium),
        subtitle: Text(
          'View application logs and error history',
          style: textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  TalkerScreen(talker: LoggerService.instance),
            ),
          );
        },
      ),
    );
  }

  Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '-';
    }
  }
}
