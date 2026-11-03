import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as legacy;
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/whats_new_page.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// The last settings sections: "Caravella" (store page, invite friends,
/// What's new and, in debug builds or with the `ENABLE_TALKER_SCREEN`
/// dart-define, the debug logs) and "Open source project" (support,
/// source code, issues), then a footer with the version, the developer's
/// site and the license.
///
/// The store row and the invite link follow the build: Google Play when
/// it has the Play review client, the F-Droid page otherwise.
class InfoSettingsSection extends StatefulWidget {
  const InfoSettingsSection({super.key});

  static const playUrl =
      'https://play.google.com/store/apps/details?id=io.caravella.egm';
  static const fdroidUrl = 'https://f-droid.org/packages/io.caravella.egm/';
  static const kofiUrl = 'https://ko-fi.com/calca';
  static const repoUrl = 'https://github.com/calca/caravella';
  static const issuesUrl = 'https://github.com/calca/caravella/issues';
  static const licenseUrl =
      'https://github.com/calca/caravella/blob/main/LICENSE';
  static const developerUrl = 'https://calca.github.io/';

  @override
  State<InfoSettingsSection> createState() => _InfoSettingsSectionState();
}

class _InfoSettingsSectionState extends State<InfoSettingsSection> {
  late final Future<String> _version = _getAppVersion();

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Show debug logs in debug mode or if build flag is enabled
    final showDebugLogs = kDebugMode || AppConfig.enableTalkerScreen;
    final store = GmsIntegrations.instance.storeReview;

    return FutureBuilder<String>(
      future: _version,
      builder: (context, snapshot) {
        final version = snapshot.data ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsGroup(
              label: loc.settings_app_section,
              children: [
                if (store != null)
                  _external(
                    context,
                    icon: Icons.star_outline_rounded,
                    title: loc.settings_rate_title,
                    subtitle: loc.settings_rate_desc,
                    onTap: () => _openStore(context, store),
                  )
                else
                  _external(
                    context,
                    icon: Icons.storefront_outlined,
                    title: loc.settings_fdroid_title,
                    subtitle: loc.settings_fdroid_desc,
                    onTap: () =>
                        _launchUrl(context, InfoSettingsSection.fdroidUrl),
                  ),
                SettingsTile(
                  icon: Icons.share_outlined,
                  title: loc.settings_invite_friends,
                  subtitle: loc.settings_invite_friends_desc,
                  onTap: () => _shareInvite(loc, store != null),
                ),
                SettingsTile(
                  icon: Icons.new_releases_outlined,
                  title: loc.settings_whats_new_version(version),
                  subtitle: loc.settings_whats_new_desc,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const WhatsNewPage()),
                  ),
                ),
                if (showDebugLogs)
                  SettingsTile(
                    icon: Icons.bug_report_outlined,
                    title: loc.settings_debug_logs_title,
                    subtitle: loc.settings_debug_logs_desc,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        // TalkerScreen is built on Flutter's classic material
                        // widgets, which look up the classic
                        // MaterialLocalizations type — not the material_ui
                        // one the app provides — and otherwise fail with
                        // "No MaterialLocalizations found".
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
            ),
            SettingsGroup(
              label: loc.settings_project_section,
              children: [
                _external(
                  context,
                  icon: Icons.coffee_outlined,
                  title: loc.support_developer_title,
                  subtitle: loc.support_developer_desc,
                  onTap: () => _launchUrl(context, InfoSettingsSection.kofiUrl),
                ),
                _external(
                  context,
                  icon: Icons.code_rounded,
                  title: loc.terms_repo_title,
                  subtitle: loc.terms_repo_desc,
                  onTap: () => _launchUrl(context, InfoSettingsSection.repoUrl),
                ),
                _external(
                  context,
                  icon: Icons.bug_report_outlined,
                  title: loc.terms_issue_title,
                  subtitle: loc.terms_issue_desc,
                  onTap: () =>
                      _launchUrl(context, InfoSettingsSection.issuesUrl),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Text(
                      loc.settings_footer_version(version),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  _footerLink(
                    context,
                    loc.settings_made_by('calca'),
                    InfoSettingsSection.developerUrl,
                  ),
                  _footerLink(
                    context,
                    loc.license_link,
                    InfoSettingsSection.licenseUrl,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// A row opening something outside the app ("open externally" icon).
  Widget _external(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: Icon(
        Icons.open_in_new_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// "· label", the label a link.
  Widget _footerLink(BuildContext context, String label, String url) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '·',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => _launchUrl(context, url),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            textStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(label),
        ),
      ],
    );
  }

  Future<void> _openStore(BuildContext context, StoreReviewClient store) async {
    try {
      await store.openStoreListing();
    } catch (e) {
      LoggerService.warning(
        'Could not open the store listing',
        name: 'settings',
      );
      if (context.mounted) _launchUrl(context, InfoSettingsSection.playUrl);
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        gen.AppLocalizations.of(context).developer_link_error,
        type: ToastType.error,
      );
      LoggerService.error('Could not launch $url', name: 'settings', error: e);
    }
  }

  Future<void> _shareInvite(gen.AppLocalizations loc, bool play) async {
    final link = play
        ? InfoSettingsSection.playUrl
        : InfoSettingsSection.fdroidUrl;
    try {
      await SharePlus.instance.share(
        ShareParams(text: loc.invite_friends_message(link)),
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
      return '';
    }
  }
}
