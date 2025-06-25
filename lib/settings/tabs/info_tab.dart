import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final localizations = AppLocalizations(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(localizations.get('about'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Caravella v0.0.3',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text('Developed by calca',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(localizations.get('links'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: Icon(Icons.person,
                size: 20, color: Theme.of(context).colorScheme.primary),
            label: Text('GitHub: calca',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            onPressed: () => _launchUrl(context, 'https://github.com/calca'),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.code,
                size: 20, color: Theme.of(context).colorScheme.primary),
            label: Text('Repository: github.com/calca/caravella',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            onPressed: () =>
                _launchUrl(context, 'https://github.com/calca/caravella'),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 8),
          Text(localizations.get('contribute'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.description,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(localizations.get('license_section'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(localizations.get('license_hint'),
              style: Theme.of(context).textTheme.bodySmall),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _launchUrl(context,
                'https://github.com/calca/caravella/blob/main/LICENSE'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.open_in_new,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(localizations.get('license_link'),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _launchUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final can = await canLaunchUrl(uri);
  if (!context.mounted) return;
  if (can) {
    await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Impossibile aprire il link: $url')),
    );
    debugPrint('Could not launch $url');
  }
}
