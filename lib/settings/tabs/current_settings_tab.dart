import 'package:flutter/material.dart';
import '../widgets/language_selector_setting.dart';
import '../widgets/theme_selector_setting.dart';
import '../../state/locale_notifier.dart';
import '../../app_localizations.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';

class CurrentSettingsTab extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const CurrentSettingsTab({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final localizations = AppLocalizations(locale);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const ThemeSelectorSetting(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.backup),
                label: Text(localizations.get('backup')),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onPressed: () async {
                  await _backupTrips(context, localizations);
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.file_upload),
                label: Text(localizations.get('import')),
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['zip', 'json'],
                  );
                  if (!context.mounted) return;
                  if (result != null && result.files.single.path != null) {
                    final filePath = result.files.single.path!;
                    final fileName = result.files.single.name;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(localizations.get('import_confirm_title')),
                        content: Text(localizations.get(
                            'import_confirm_message',
                            params: {'file': fileName})),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localizations.get('cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(localizations.get('ok')),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        final dir = await getApplicationDocumentsDirectory();
                        final destFile = File('${dir.path}/trips.json');
                        if (filePath.endsWith('.zip')) {
                          final bytes = await File(filePath).readAsBytes();
                          final archive = ZipDecoder().decodeBytes(bytes);
                          for (final file in archive) {
                            if (file.name == 'trips.json') {
                              await destFile
                                  .writeAsBytes(file.content as List<int>);
                              break;
                            }
                          }
                        } else if (filePath.endsWith('.json')) {
                          await File(filePath).copy(destFile.path);
                        }
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(localizations.get('import_success'))),
                        );
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        final state = context.findAncestorStateOfType<State>();
                        if (state != null && state.mounted) {
                          // ignore: invalid_use_of_protected_member
                          state.setState(() {});
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(localizations.get('import_error'))),
                        );
                      }
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
    final now = DateTime.now();
    final dateStr =
        "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
    final zipPath = '${tempDir.path}/$dateStr-caravella_backup.zip';
    zipEncoder.create(zipPath);
    zipEncoder.addFile(tripsFile);
    zipEncoder.close();
    if (!context.mounted) return;
    final params = ShareParams(
      text: loc.get('backup_share_message'),
      files: [XFile(zipPath)],
    );
    await SharePlus.instance.share(params);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.get('backup_error'))),
    );
  }
}
