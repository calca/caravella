import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../data/expense_group_storage.dart';

class GoogleDriveBackupService {
  static const String _backupFileName = 'caravella_backup.json';
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Sign in to Google Drive
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Sign out from Google Drive
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Upload backup to Google Drive
  Future<void> uploadBackup() async {
    if (!isSignedIn) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      // Get the local JSON file
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/${ExpenseGroupStorage.fileName}');
      
      if (!await localFile.exists()) {
        throw Exception('No local backup file found');
      }

      // Get authenticated HTTP client
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        throw Exception('Failed to get authenticated client');
      }

      final driveApi = drive.DriveApi(authClient);

      // Check if backup file already exists
      final existingFiles = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'drive',
      );

      final fileContent = await localFile.readAsBytes();
      final media = drive.Media(Stream.value(fileContent), fileContent.length);

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        // Update existing file
        final existingFileId = existingFiles.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = _backupFileName
          ..description = 'Caravella expense groups backup';

        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }
    } catch (e) {
      throw Exception('Failed to upload backup: $e');
    }
  }

  /// Download backup from Google Drive
  Future<void> downloadBackup() async {
    if (!isSignedIn) {
      throw Exception('Not signed in to Google Drive');
    }

    try {
      // Get authenticated HTTP client
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        throw Exception('Failed to get authenticated client');
      }

      final driveApi = drive.DriveApi(authClient);

      // Find the backup file
      final files = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'drive',
      );

      if (files.files == null || files.files!.isEmpty) {
        throw Exception('No backup file found on Google Drive');
      }

      final fileId = files.files!.first.id!;
      
      // Download the file
      final drive.Media fileContent = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Save to local storage
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/${ExpenseGroupStorage.fileName}');
      
      final bytes = <int>[];
      await for (final chunk in fileContent.stream) {
        bytes.addAll(chunk);
      }
      
      await localFile.writeAsBytes(bytes);
    } catch (e) {
      throw Exception('Failed to download backup: $e');
    }
  }

  /// Check if a backup exists on Google Drive
  Future<bool> hasBackupOnDrive() async {
    if (!isSignedIn) {
      return false;
    }

    try {
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        return false;
      }

      final driveApi = drive.DriveApi(authClient);
      final files = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'drive',
      );

      return files.files != null && files.files!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get backup info from Google Drive
  Future<drive.File?> getBackupInfo() async {
    if (!isSignedIn) {
      return null;
    }

    try {
      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        return null;
      }

      final driveApi = drive.DriveApi(authClient);
      final files = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'drive',
        $fields: 'files(id,name,modifiedTime,size)',
      );

      if (files.files != null && files.files!.isNotEmpty) {
        return files.files!.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}