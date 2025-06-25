import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final localizations = AppLocalizations(locale);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FractionallySizedBox(
          widthFactor: 1.0,
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface.withAlpha(242),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 12),
                  Text('Caravella v0.0.3',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Developed by calca',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.link,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(localizations.get('links'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: Icon(Icons.person,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    label: Text('GitHub: calca',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    onPressed: () => _launchUrl('https://github.com/calca'),
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    onPressed: () =>
                        _launchUrl('https://github.com/calca/caravella'),
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.description,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(localizations.get('license_section'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(localizations.get('license_hint'),
                      style: Theme.of(context).textTheme.bodySmall),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launchUrl(
                        'https://github.com/calca/caravella/blob/main/LICENSE'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(localizations.get('license_link'),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    debugPrint('Could not launch $url');
  }
}
