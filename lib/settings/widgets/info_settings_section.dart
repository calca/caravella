import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as legacy;
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

    return SettingsGroup(
      label: loc.settings_info,
      children: [
        SettingsTile(
          icon: Icons.share_outlined,
          title: loc.settings_invite_friends,
          subtitle: loc.settings_invite_friends_desc,
          onTap: () => _shareInvite(context, loc),
        ),
        SettingsTile(
          icon: Icons.info_outline,
          title: loc.settings_info_card,
          subtitle: loc.settings_info_card_desc,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const DeveloperPage())),
        ),
        SettingsTile(
          icon: Icons.new_releases_outlined,
          title: loc.settings_app_version,
          subtitleWidget: FutureBuilder<String>(
            future: _getAppVersion(),
            builder: (context, snapshot) => Text(snapshot.data ?? '-'),
          ),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const WhatsNewPage())),
        ),
        if (showDebugLogs)
          SettingsTile(
            icon: Icons.bug_report_outlined,
            title: loc.settings_debug_logs_title,
            subtitle: loc.settings_debug_logs_desc,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                // TalkerScreen is built on Flutter's classic material
                // widgets, which look up the classic MaterialLocalizations
                // type — not the material_ui one the app provides — and
                // otherwise fail with "No MaterialLocalizations found".
                builder: (context) => Localizations.override(
                  context: context,
                  delegates: const [
                    legacy.GlobalMaterialLocalizations.delegate,
                    legacy.GlobalCupertinoLocalizations.delegate,
                  ],
                  child: TalkerScreen(talker: LoggerService.instance),
                ),
              ),
            ),
          ),
      ],
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

  Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '-';
    }
  }
}
