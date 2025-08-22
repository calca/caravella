import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../data/expense_group_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../widgets/app_toast.dart';
import 'auto_backup_notifier.dart';
import 'package:provider/provider.dart';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ChangeNotifierProvider<AutoBackupNotifier>(
      create: (_) => AutoBackupNotifier(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gloc.data_title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer<AutoBackupNotifier>(
                  builder: (context, notifier, _) => Semantics(
                    toggled: notifier.enabled,
                    label:
                        '${gloc.auto_backup_title} - ${notifier.enabled ? gloc.accessibility_currently_enabled : gloc.accessibility_currently_disabled}',
                    hint: notifier.enabled
                        ? gloc.accessibility_double_tap_disable
                        : gloc.accessibility_double_tap_enable,
                    child: ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: Text(
                        gloc.auto_backup_title,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        gloc.auto_backup_desc,
                        style: textTheme.bodySmall,
                      ),
                      trailing: Semantics(
                        label: gloc.accessibility_security_switch(
                          notifier.enabled
                              ? gloc.accessibility_switch_on
                              : gloc.accessibility_switch_off,
                        ),
                        child: Switch(
                          value: notifier.enabled,
                          onChanged: (val) async {
                            notifier.setEnabled(val);
                          },
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined),
                  minLeadingWidth: 0,
                  title: Text(gloc.backup, style: textTheme.titleMedium),
                  subtitle: Text(gloc.data_backup_desc),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () async {
                    await _backupTrips(context, gloc);
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.download_outlined),
                  minLeadingWidth: 0,
                  title: Text(
                    gloc.data_restore_title,
                    style: textTheme.titleMedium,
                  ),
                  subtitle: Text(gloc.data_restore_desc),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () async {
                    await _importTrips(context, gloc);
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _backupTrips(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final tripsFile = File('${dir.path}/${ExpenseGroupStorage.fileName}');

      if (!await tripsFile.exists()) {
        if (!context.mounted) return;
        AppToast.show(context, loc.no_trips_to_backup, type: ToastType.info);
        return;
      }

      final fileSize = await tripsFile.length();
      if (fileSize == 0) {
        if (!context.mounted) return;
        AppToast.show(context, loc.no_trips_to_backup, type: ToastType.info);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateStr =
          "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final zipPath = '${tempDir.path}/caravella_backup_$dateStr.zip';

      // Create archive manually to ensure file content is properly added
      final archive = Archive();
      final fileBytes = await tripsFile.readAsBytes();
      final archiveFile = ArchiveFile(
        ExpenseGroupStorage.fileName,
        fileBytes.length,
        fileBytes,
      );
      archive.addFile(archiveFile);
      final zipData = ZipEncoder().encode(archive);
      await File(zipPath).writeAsBytes(zipData);

      if (!context.mounted) return;

      final params = ShareParams(
        text: loc.backup_share_message,
        files: [XFile(zipPath)],
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        '${loc.backup_error}: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  Future<void> _importTrips(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
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
          title: Text(loc.import_confirm_title),
          content: Text(loc.import_confirm_message(fileName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.ok),
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
          AppToast.show(context, loc.import_success, type: ToastType.success);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
          if (!context.mounted) return;
          AppToast.show(
            context,
            '${loc.import_error}: ${e.toString()}',
            type: ToastType.error,
          );
        }
      }
    }
  }
}
