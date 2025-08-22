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
import '../services/google_drive_backup_service.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final GoogleDriveBackupService _googleDriveService = GoogleDriveBackupService();

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
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
            const SizedBox(height: 16),
            // Local Backup Card
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
            // Local Restore Card
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
            // Google Drive Section - Android only
            if (Platform.isAndroid) ...[
              const SizedBox(height: 32),
              Text(
                'Google Drive',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Google Drive Authentication Status
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(_googleDriveService.isSignedIn 
                    ? Icons.account_circle 
                    : Icons.account_circle_outlined),
                  minLeadingWidth: 0,
                  title: Text(
                    _googleDriveService.isSignedIn 
                      ? gloc.google_drive_signed_in_as(_googleDriveService.currentUser?.email ?? '')
                      : gloc.google_drive_sign_in,
                    style: textTheme.titleMedium,
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      if (_googleDriveService.isSignedIn) {
                        await _googleDriveSignOut(context, gloc);
                      } else {
                        await _googleDriveSignIn(context, gloc);
                      }
                    },
                    child: Text(_googleDriveService.isSignedIn 
                      ? gloc.google_drive_sign_out 
                      : gloc.google_drive_sign_in),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
              ),
              // Google Drive Backup Card  
              if (_googleDriveService.isSignedIn) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    minLeadingWidth: 0,
                    title: Text(gloc.google_drive_backup, style: textTheme.titleMedium),
                    subtitle: Text(gloc.google_drive_backup_desc),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      await _googleDriveBackup(context, gloc);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Google Drive Restore Card
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_download),
                    minLeadingWidth: 0,
                    title: Text(gloc.google_drive_restore, style: textTheme.titleMedium),
                    subtitle: Text(gloc.google_drive_restore_desc),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      await _googleDriveRestore(context, gloc);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ],
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

  Future<void> _googleDriveSignIn(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      final account = await _googleDriveService.signIn();
      if (account != null && context.mounted) {
        AppToast.show(
          context,
          loc.google_drive_signed_in_as(account.email),
          type: ToastType.success,
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        '${loc.google_drive_auth_error}: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  Future<void> _googleDriveSignOut(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      await _googleDriveService.signOut();
      if (context.mounted) {
        AppToast.show(
          context,
          loc.google_drive_sign_out,
          type: ToastType.info,
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        '${loc.google_drive_auth_error}: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  Future<void> _googleDriveBackup(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      // Show uploading message
      AppToast.show(context, loc.google_drive_uploading, type: ToastType.info);
      
      await _googleDriveService.uploadBackup();
      
      if (!context.mounted) return;
      AppToast.show(
        context,
        loc.google_drive_backup_success,
        type: ToastType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        '${loc.google_drive_backup_error}: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  Future<void> _googleDriveRestore(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    // Check if backup exists first
    final hasBackup = await _googleDriveService.hasBackupOnDrive();
    if (!hasBackup) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        loc.google_drive_no_backup_found,
        type: ToastType.info,
      );
      return;
    }

    // Confirm restore
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(loc.import_confirm_title),
        content: Text(loc.import_confirm_message('Google Drive backup')),
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

    if (confirm != true) return;

    try {
      // Show downloading message
      AppToast.show(context, loc.google_drive_downloading, type: ToastType.info);
      
      await _googleDriveService.downloadBackup();
      
      if (!context.mounted) return;
      AppToast.show(
        context,
        loc.google_drive_restore_success,
        type: ToastType.success,
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        '${loc.google_drive_restore_error}: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }
}
