import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/caravella_app_bar.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../state/theme_mode_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../data/expense_group_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'terms_page.dart';
import 'data_page.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CaravellaAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Generali',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: Text('Lingua', style: textTheme.titleMedium),
                    subtitle: Text(locale == 'it' ? 'Italiano' : 'English'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          String selectedLocale = locale;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Seleziona lingua',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 8),
                                    RadioListTile<String>(
                                      value: 'it',
                                      groupValue: selectedLocale,
                                      title: const Text('Italiano'),
                                      onChanged: (value) {
                                        setState(() => selectedLocale = value!);
                                        LocaleNotifier.of(context)
                                            ?.changeLocale(value!);
                                        if (onLocaleChanged != null) {
                                          onLocaleChanged!(value!);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<String>(
                                      value: 'en',
                                      groupValue: selectedLocale,
                                      title: const Text('English'),
                                      onChanged: (value) {
                                        setState(() => selectedLocale = value!);
                                        LocaleNotifier.of(context)
                                            ?.changeLocale(value!);
                                        if (onLocaleChanged != null) {
                                          onLocaleChanged!(value!);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text('Tema', style: textTheme.titleMedium),
                    subtitle: Text(loc.get('theme_automatic')),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () {
                      final themeMode =
                          ThemeModeNotifier.of(context)?.themeMode ??
                              ThemeMode.system;
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          ThemeMode selectedMode = themeMode;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Seleziona tema',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 8),
                                    RadioListTile<ThemeMode>(
                                      value: ThemeMode.system,
                                      groupValue: selectedMode,
                                      title: Text(loc.get('theme_automatic')),
                                      onChanged: (value) {
                                        setState(() => selectedMode = value!);
                                        ThemeModeNotifier.of(context)
                                            ?.changeTheme(value!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<ThemeMode>(
                                      value: ThemeMode.light,
                                      groupValue: selectedMode,
                                      title: Text(loc.get('theme_light')),
                                      onChanged: (value) {
                                        setState(() => selectedMode = value!);
                                        ThemeModeNotifier.of(context)
                                            ?.changeTheme(value!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<ThemeMode>(
                                      value: ThemeMode.dark,
                                      groupValue: selectedMode,
                                      title: Text(loc.get('theme_dark')),
                                      onChanged: (value) {
                                        setState(() => selectedMode = value!);
                                        ThemeModeNotifier.of(context)
                                            ?.changeTheme(value!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Dati',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 0,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: Text('Gestione dati', style: textTheme.titleMedium),
                subtitle: Text('Backup e importazione'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const DataPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Informazioni',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title:
                        Text("Versione dell'app", style: textTheme.titleMedium),
                    subtitle: FutureBuilder<String>(
                      future: _getAppVersion(),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? '-');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text('Informazioni', style: textTheme.titleMedium),
                    subtitle: Text('Sviluppatore, Source code e Licenza', style: textTheme.bodySmall),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const TermsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '-';
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

  Future<void> _importTrips(BuildContext context, AppLocalizations loc) async {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(loc.get('import_confirm_title')),
          content: Text(
              loc.get('import_confirm_message', params: {'file': fileName})),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.get('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.get('ok')),
            ),
          ],
        ),
      );
      if (confirm == true) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final destFile = File('${dir.path}/${ExpenseGroupStorage.fileName}');
          if (filePath.endsWith('.zip')) {
            final bytes = await File(filePath).readAsBytes();
            final archive = ZipDecoder().decodeBytes(bytes);
            bool fileFound = false;
            for (final file in archive) {
              if (file.name == ExpenseGroupStorage.fileName) {
                await destFile.writeAsBytes(file.content as List<int>);
                fileFound = true;
                break;
              }
            }
            if (!fileFound) {
              throw Exception('File di backup non trovato nell\'archivio');
            }
          } else if (filePath.endsWith('.json')) {
            await File(filePath).copy(destFile.path);
          } else {
            throw Exception('Formato file non supportato');
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.get('import_success'))),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${loc.get('import_error')}: ${e.toString()}')),
          );
        }
      }
    }
  }
}
