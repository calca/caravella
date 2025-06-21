import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  final AppLocalizations localizations;
  const SettingsPage({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.get('about'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Caravella v0.0.3', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Developed by calca', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            const SizedBox(height: 32),
            Text('Links', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchUrl('https://github.com/calca'),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Text('GitHub: calca', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchUrl('https://github.com/calca/caravella'),
              child: Row(
                children: [
                  const Icon(Icons.code, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Repository: github.com/calca/caravella', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Contribute to the project! Pull requests and feedback are welcome.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 32),
            Text(localizations.get('license_section'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(localizations.get('license_hint'), style: Theme.of(context).textTheme.bodySmall),
            InkWell(
              onTap: () => _launchUrl('https://github.com/calca/caravella/blob/main/LICENSE'),
              child: Row(
                children: [
                  const Icon(Icons.description, size: 20),
                  const SizedBox(width: 8),
                  Text(localizations.get('license_link'), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // Optionally show a snackbar or dialog if the URL can't be launched
    debugPrint('Could not launch $url');
  }
}
