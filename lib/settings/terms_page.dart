import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
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
          Card(
            elevation: 0,
            color: colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person,
                        color: colorScheme.onSurface, size: 20),
                    title: Text(loc.get('terms_github_title'),
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface)),
                    subtitle: Text(loc.get('terms_github_desc'),
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurface)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () =>
                        _launchUrl(context, 'https://github.com/calca'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.code,
                        color: colorScheme.onSurface, size: 20),
                    title: Text(loc.get('terms_repo_title'),
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface)),
                    subtitle: Text(loc.get('terms_repo_desc'),
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurface)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchUrl(
                        context, 'https://github.com/calca/caravella'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.bug_report,
                        color: colorScheme.onSurface, size: 20),
                    title: Text(loc.get('terms_issue_title'),
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface)),
                    subtitle: Text(loc.get('terms_issue_desc'),
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurface)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchUrl(
                        context, 'https://github.com/calca/caravella/issues'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 8,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.open_in_new,
                        color: colorScheme.onSurface, size: 20),
                    title: Text(loc.get('license_link'),
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface)),
                    subtitle: Text(loc.get('terms_license_desc'),
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurface)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _launchUrl(context,
                        'https://github.com/calca/caravella/blob/main/LICENSE'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile aprire il link: $url')),
      );
      debugPrint('Could not launch $url: $e');
    }
  }
}
