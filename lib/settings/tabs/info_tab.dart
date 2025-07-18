import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final localizations = AppLocalizations(locale);
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: colorScheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(localizations.get('about'),
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Text('Caravella ...', style: textTheme.bodyMedium);
                    }
                    final info = snapshot.data;
                    final version = info?.version ?? '-';
                    return Text('Caravella v$version ($flavor)',
                        style: textTheme.bodyMedium);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.link, color: colorScheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(localizations.get('links'),
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.person, color: colorScheme.primary, size: 20),
                  title: Text('GitHub: calca',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.primary)),
                  onTap: () => _launchUrl(context, 'https://github.com/calca'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minLeadingWidth: 0,
                  horizontalTitleGap: 8,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Icon(Icons.code, color: colorScheme.primary, size: 20),
                  title: Text('GitHub Repository',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.primary)),
                  onTap: () =>
                      _launchUrl(context, 'https://github.com/calca/caravella'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minLeadingWidth: 0,
                  horizontalTitleGap: 8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description,
                        color: colorScheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(localizations.get('license_section'),
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(localizations.get('license_hint'),
                    style: textTheme.bodySmall),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.open_in_new,
                      color: colorScheme.primary, size: 20),
                  title: Text(localizations.get('license_link'),
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.primary)),
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
    );
  }
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
