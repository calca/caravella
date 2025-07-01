import 'package:flutter/material.dart';
import '../widgets/language_selector_setting.dart';
import '../widgets/theme_selector_setting.dart';
import '../../state/locale_notifier.dart';
import '../../app_localizations.dart';
import '../../data/expense_group_storage.dart';
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
            // SEZIONE BACKUP E RIPRISTINO
            Text(
              'Backup e Ripristino',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.backup_rounded, size: 20),
                      label: Text(localizations.get('backup')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      onPressed: () async {
                        await _backupTrips(context, localizations);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.file_upload_rounded, size: 20),
                      label: Text(localizations.get('import')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['zip', 'json'],
                        );
                        if (!context.mounted) return;
                        if (result != null &&
                            result.files.single.path != null) {
                          final filePath = result.files.single.path!;
                          final fileName = result.files.single.name;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                  localizations.get('import_confirm_title')),
                              content: Text(localizations.get(
                                  'import_confirm_message',
                                  params: {'file': fileName})),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(localizations.get('cancel')),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(localizations.get('ok')),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              final dir =
                                  await getApplicationDocumentsDirectory();
                              final destFile = File(
                                  '${dir.path}/${ExpenseGroupStorage.fileName}');

                              if (filePath.endsWith('.zip')) {
                                final bytes =
                                    await File(filePath).readAsBytes();
                                final archive = ZipDecoder().decodeBytes(bytes);

                                bool fileFound = false;
                                for (final file in archive) {
                                  if (file.name == ExpenseGroupStorage.fileName) {
                                    await destFile.writeAsBytes(
                                        file.content as List<int>);
                                    fileFound = true;
                                    break;
                                  }
                                }

                                if (!fileFound) {
                                  throw Exception(
                                      'File di backup non trovato nell\'archivio');
                                }
                              } else if (filePath.endsWith('.json')) {
                                await File(filePath).copy(destFile.path);
                              } else {
                                throw Exception('Formato file non supportato');
                              }

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        localizations.get('import_success'))),
                              );

                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                              final state =
                                  context.findAncestorStateOfType<State>();
                              if (state != null && state.mounted) {
                                // ignore: invalid_use_of_protected_member
                                state.setState(() {});
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${localizations.get('import_error')}: ${e.toString()}')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
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
    final tripsFile = File('${dir.path}/${ExpenseGroupStorage.fileName}');

    if (!await tripsFile.exists()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.get('no_trips_to_backup'))),
      );
      return;
    }

    final fileSize = await tripsFile.length();
    if (fileSize == 0) {
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
    final zipPath = '${tempDir.path}/caravella_backup_$dateStr.zip';

    zipEncoder.create(zipPath);
    zipEncoder.addFile(tripsFile, ExpenseGroupStorage.fileName);
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
      SnackBar(content: Text('${loc.get('backup_error')}: ${e.toString()}')),
    );
  }
}
