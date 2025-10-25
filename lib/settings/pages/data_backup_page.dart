import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/expense_group_storage_v2.dart';
import '../../data/model/expense_group.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../widgets/app_toast.dart';
import '../../widgets/material3_dialog.dart';
import '../auto_backup_notifier.dart';
import 'package:provider/provider.dart';
import '../../manager/group/widgets/section_header.dart';

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
      // Get all groups from the repository (works with both JSON and Hive backends)
      final allGroups = await ExpenseGroupStorageV2.getAllGroups();
      
      if (allGroups.isEmpty) {
        if (!context.mounted) return;
        AppToast.show(context, loc.no_trips_to_backup, type: ToastType.info);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateStr =
          "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final zipPath = '${tempDir.path}/caravella_backup_$dateStr.zip';

      // Convert all groups to JSON and create a backup file
      final jsonData = allGroups.map((g) => g.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final jsonBytes = utf8.encode(jsonString);

      // Create archive with the JSON data
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
      if (confirm == true) {
        try {
          // Parse the backup file to get the groups
          List<dynamic> jsonData;
          
          if (filePath.endsWith('.zip')) {
            final bytes = await File(filePath).readAsBytes();
            final archive = ZipDecoder().decodeBytes(bytes);
            bool fileFound = false;
            for (final file in archive) {
              if (file.name == ExpenseGroupStorageV2.fileName) {
                final content = utf8.decode(file.content as List<int>);
                jsonData = json.decode(content) as List<dynamic>;
                fileFound = true;
                break;
              }
            }
            if (!fileFound) {
              throw Exception('File di backup non trovato nell\'archivio');
            }
          } else if (filePath.endsWith('.json')) {
            final content = await File(filePath).readAsString();
            jsonData = json.decode(content) as List<dynamic>;
          } else {
            throw Exception('Formato file non supportato');
          }
          
          // Import groups into the current backend (JSON or Hive)
          final groups = jsonData
              .map((j) => ExpenseGroup.fromJson(j as Map<String, dynamic>))
              .toList();
          
          // Add each group to storage using the repository
          for (final group in groups) {
            await ExpenseGroupStorageV2.addExpenseGroup(group);
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
