import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/settings/widgets/settings_card.dart';
import '../../settings/widgets/settings_section.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_toast.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  Widget _buildBuyMeCoffeeRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      semanticsButton: true,
      semanticsLabel: loc.support_developer_title,
      semanticsHint: 'Double tap to support the developer',
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.coffee_outlined),
        title: Text(loc.support_developer_title, style: textTheme.titleMedium),
        subtitle: Text(loc.support_developer_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.launch, size: 16),
        onTap: () =>
            _launchUrl(context, 'https://buymeacoffee.com/gianluigick'),
      ),
    );
  }

  Widget _buildGithubRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(Icons.person_outline),
        title: Text(loc.terms_github_title, style: textTheme.titleMedium),
        subtitle: Text(loc.terms_github_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.launch, size: 16),
        onTap: () => _launchUrl(context, 'https://github.com/calca'),
      ),
    );
  }

  Widget _buildRepoRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(Icons.code_outlined),
        title: Text(loc.terms_repo_title, style: textTheme.titleMedium),
        subtitle: Text(loc.terms_repo_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.launch, size: 16),
        onTap: () => _launchUrl(context, 'https://github.com/calca/caravella'),
      ),
    );
  }

  Widget _buildIssueRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(Icons.bug_report_outlined),
        title: Text(loc.terms_issue_title, style: textTheme.titleMedium),
        subtitle: Text(loc.terms_issue_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.launch, size: 16),
        onTap: () =>
            _launchUrl(context, 'https://github.com/calca/caravella/issues'),
      ),
    );
  }

  Widget _buildLicenseRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(Icons.open_in_new),
        title: Text(loc.license_link, style: textTheme.titleMedium),
        subtitle: Text(loc.terms_license_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.launch, size: 16),
        onTap: () => _launchUrl(
          context,
          'https://github.com/calca/caravella/blob/main/LICENSE',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          SettingsSection(
            title: loc.developer_section_title,
            description: loc.developer_section_desc,
            children: [
              _buildBuyMeCoffeeRow(context, loc),
              _buildGithubRow(context, loc),
            ],
          ),
          const SizedBox(height: 8),
          SettingsSection(
            title: loc.repo_section_title,
            description: loc.repo_section_desc,
            children: [
              _buildRepoRow(context, loc),
              _buildIssueRow(context, loc),
            ],
          ),
          SettingsSection(
            title: loc.license_section_title,
            description: loc.license_section_desc,
            children: [_buildLicenseRow(context, loc)],
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
        'Impossibile aprire il link: $url',
        type: ToastType.error,
      );
      debugPrint('Could not launch $url: $e');
    }
  }
}
