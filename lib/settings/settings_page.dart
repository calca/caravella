import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'language_selector_setting.dart';
import 'theme_selector_setting.dart';
import '../state/locale_notifier.dart';
import '../widgets/caravella_app_bar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final localizations = AppLocalizations(locale);
    return Scaffold(
      appBar: CaravellaAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Language selector (aligned with theme selector) ---
            LanguageSelectorSetting(
              locale: localizations.locale,
              onChanged: (selected) {
                LocaleNotifier.of(context)?.changeLocale(selected);
                if (onLocaleChanged != null) {
                  onLocaleChanged!(selected);
                }
              },
            ),
            const SizedBox(height: 16),
            // --- Theme selector ---
            const ThemeSelectorSetting(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: Text(localizations.get('backup')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                await _backupTrips(context, localizations);
              },
            ),
            const SizedBox(height: 24),
            Divider(height: 1, thickness: 1),
            const SizedBox(height: 32),
            // --- Info Section ---
            FractionallySizedBox(
              widthFactor: 1.0,
              child: Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
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
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

Future<void> _backupTrips(BuildContext context, AppLocalizations loc) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final tripsFile = File('${dir.path}/trips.json');
    if (!await tripsFile.exists()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.get('no_trips_to_backup'))),
      );
      return;
    }
    final zipEncoder = ZipFileEncoder();
    final tempDir = await getTemporaryDirectory();
    final zipPath = '${tempDir.path}/caravella_backup.zip';
    zipEncoder.create(zipPath);
    zipEncoder.addFile(tripsFile);
    zipEncoder.close();
    if (!context.mounted) return;
    await Share.shareXFiles([XFile(zipPath)],
        text: loc.get('backup_share_message'));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.get('backup_error'))),
    );
  }
}
