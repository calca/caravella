import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
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

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildBuyMeCoffeeRow(context, loc),
          const SizedBox(height: 8),
          SettingsCard(
            context: context,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.person_outline,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(
                      loc.terms_github_title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      loc.terms_github_desc,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () =>
                        _launchUrl(context, 'https://github.com/calca'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.code_outlined,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(
                      loc.terms_repo_title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      loc.terms_repo_desc,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchUrl(
                      context,
                      'https://github.com/calca/caravella',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.bug_report_outlined,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(
                      loc.terms_issue_title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      loc.terms_issue_desc,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchUrl(
                      context,
                      'https://github.com/calca/caravella/issues',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.open_in_new,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    title: Text(
                      loc.license_link,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      loc.terms_license_desc,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchUrl(
                      context,
                      'https://github.com/calca/caravella/blob/main/LICENSE',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                ],
              ),
            ),
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
