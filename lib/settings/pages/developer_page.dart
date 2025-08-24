import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'package:org_app_caravella/manager/group/widgets/section_header.dart';
import 'package:org_app_caravella/settings/widgets/settings_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_toast.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  Future<void> _launchBuyMeCoffee() async {
    const url = 'https://buymeacoffee.com/gianluigick';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently - user can try again if needed
    }
  }

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
        onTap: () => _launchBuyMeCoffee(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        children: [
          SectionHeader(
            title: "Developer",
            description: "Information and links to support the developer",
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          ),
          _buildGithubRow(context, loc),
          _buildBuyMeCoffeeRow(context, loc),
          SectionHeader(
            title: "Contribute",
            description: "Information and links to support contributions",
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          ),
          _buildRepoRow(context, loc),
          _buildIssueRow(context, loc),
          SectionHeader(
            title: "Other",
            description: "Information and links to support other aspects",
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          ),
          _buildLicenseRow(context, loc),
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
