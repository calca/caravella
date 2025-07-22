import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../data/expense_group_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DataPage extends StatelessWidget {
  final AppLocalizations? loc;
  const DataPage({super.key, this.loc});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final localization = loc ?? AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dati'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dati',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(localization.get('backup')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      await _backupTrips(context, localization);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download_outlined),
                    label: Text(localization.get('import')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      await _importTrips(context, localization);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
