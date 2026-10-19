import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:url_launcher/url_launcher.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  /// A row opening [url] outside the app (trailing "open externally" icon).
  Widget _link(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => _launchUrl(context, url),
      trailing: Icon(
        Icons.open_in_new_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.settings,
        title: loc.settings_info_card,
        children: [
          SettingsGroup(
            label: loc.developer_section_title,
            children: [
              _link(
                context,
                icon: Icons.coffee_outlined,
                title: loc.support_developer_title,
                subtitle: loc.support_developer_desc,
                url: 'https://ko-fi.com/calca',
              ),
              _link(
                context,
                icon: Icons.person_outline,
                title: loc.terms_github_title,
                subtitle: loc.terms_github_desc,
                url: 'https://calca.github.io/',
              ),
            ],
          ),
          SettingsGroup(
            label: loc.repo_section_title,
            children: [
              _link(
                context,
                icon: Icons.code_outlined,
                title: loc.terms_repo_title,
                subtitle: loc.terms_repo_desc,
                url: 'https://github.com/calca/caravella',
              ),
              _link(
                context,
                icon: Icons.bug_report_outlined,
                title: loc.terms_issue_title,
                subtitle: loc.terms_issue_desc,
                url: 'https://github.com/calca/caravella/issues',
              ),
            ],
          ),
          SettingsGroup(
            label: loc.license_section_title,
            children: [
              _link(
                context,
                icon: Icons.gavel_outlined,
                title: loc.license_link,
                subtitle: loc.terms_license_desc,
                url: 'https://github.com/calca/caravella/blob/main/LICENSE',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
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
}
