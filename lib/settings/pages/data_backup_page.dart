import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

class DataBackupPage extends StatelessWidget {
  const DataBackupPage({super.key});

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
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            // Auto Backup Section
            SectionHeader(
              title: gloc.auto_backup_title,
              description: gloc.auto_backup_desc,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
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
            ),

            // Manual Backup & Restore Section
            SectionHeader(
              title: gloc.data_title,
              description: gloc.settings_data_desc,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                  const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Future<void> _backupTrips(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      // Use storage APIs to get all groups
      final groups = await ExpenseGroupStorageV2.getAllGroups();

      if (groups.isEmpty) {
        if (!context.mounted) return;
        AppToast.show(context, loc.no_trips_to_backup, type: ToastType.info);
        return;
      }

      // Serialize groups to JSON
      final jsonData = jsonEncode(groups.map((g) => g.toJson()).toList());
      final jsonBytes = utf8.encode(jsonData);

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateStr =
          "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final zipPath = '${tempDir.path}/caravella_backup_$dateStr.zip';

      // Create archive manually to ensure file content is properly added
      final archive = Archive();
      final archiveFile = ArchiveFile(
        ExpenseGroupStorageV2.fileName,
        jsonBytes.length,
        jsonBytes,
      );
      archive.addFile(archiveFile);
      final zipData = ZipEncoder().encode(archive);
      await File(zipPath).writeAsBytes(zipData);

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(text: loc.backup_share_message, files: [XFile(zipPath)]),
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to create backup',
        name: 'settings.backup',
        error: e,
        stackTrace: st,
      );
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
        builder: (context) => Material3Dialog(
          icon: Icon(
            Icons.upload_file_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          title: Text(loc.import_confirm_title),
          content: Text(loc.import_confirm_message(fileName)),
          actions: [
            Material3DialogActions.cancel(context, loc.cancel),
            Material3DialogActions.primary(
              context,
              loc.ok,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        try {
          late final String jsonContent;

          // Extract JSON content based on file type
          if (filePath.endsWith('.zip')) {
            final bytes = await File(filePath).readAsBytes();
            final archive = ZipDecoder().decodeBytes(bytes);
            bool fileFound = false;
            for (final file in archive) {
              if (file.name == ExpenseGroupStorageV2.fileName) {
                jsonContent = utf8.decode(file.content as List<int>);
                fileFound = true;
                break;
              }
            }
            if (!fileFound) {
              throw Exception('File di backup non trovato nell\'archivio');
            }
          } else if (filePath.endsWith('.json')) {
            jsonContent = await File(filePath).readAsString();
          } else {
            throw Exception('Formato file non supportato');
          }

          // Parse JSON and deserialize groups
          final List<dynamic> jsonList = jsonDecode(jsonContent);
          final groups = jsonList
              .map(
                (json) => ExpenseGroup.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          if (groups.isEmpty) {
            throw Exception('Nessun gruppo trovato nel backup');
          }

          // Use storage APIs to save each group
          final repository = ExpenseGroupStorageV2.repository;
          for (final group in groups) {
            final saveResult = await repository.saveGroup(group);
            if (!saveResult.isSuccess) {
              throw Exception(
                'Errore nel salvare il gruppo "${group.title}": ${saveResult.error?.message}',
              );
            }
          }

          // Notify that data has changed
          if (context.mounted) {
            final notifier = context.read<ExpenseGroupNotifier>();
            for (final group in groups) {
              notifier.notifyGroupUpdated(group.id);
            }

            // Mark that user has groups (no longer first start)
            try {
              await PreferencesService.instance.appState.setIsFirstStart(false);
            } catch (e, st) {
              LoggerService.error(
                'Failed to update first start preference',
                name: 'settings.backup',
                error: e,
                stackTrace: st,
              );
            }

            AppToast.show(context, loc.import_success, type: ToastType.success);
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } catch (e, st) {
          LoggerService.error(
            'Failed to import backup',
            name: 'settings.backup',
            error: e,
            stackTrace: st,
          );
          if (context.mounted) {
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
}
