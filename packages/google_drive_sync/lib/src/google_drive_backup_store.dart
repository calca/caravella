import 'package:caravella_core/caravella_core.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'google_drive_auth_service.dart';

/// [CloudBackupStore] in the user's Google Drive `appDataFolder` (the same
/// hidden, per-app space and sign-in as cloud sync): backup zips named
/// `caravella_backup_*.zip`, the newest few kept.
class GoogleDriveBackupStore implements CloudBackupStore {
  static const _tag = 'backup.drive';
  static const _prefix = 'caravella_backup_';

  final GoogleDriveAuthService _auth;

  GoogleDriveBackupStore(this._auth);

  @override
  String get providerName => 'Google Drive';

  @override
  String? get accountName => _auth.currentUser?.email;

  @override
  Future<bool> restoreSession() async => (await _auth.signInSilently()) != null;

  @override
  Future<bool> signIn() async => (await _auth.signIn()) != null;

  @override
  Future<void> signOut() => _auth.signOut();

  Future<drive.DriveApi> _api() async {
    final client = await _auth.authenticatedClient();
    if (client == null) {
      throw StateError('Not signed in to Google Drive');
    }
    return drive.DriveApi(client);
  }

  @override
  Future<CloudBackupEntry> upload(
    String fileName,
    List<int> bytes, {
    int keep = 5,
  }) async {
    final api = await _api();
    final created = await api.files.create(
      drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'],
      uploadMedia: drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/zip',
      ),
      $fields: 'id, name, createdTime, size',
    );
    LoggerService.info(
      'Uploaded backup $fileName (${bytes.length} bytes)',
      name: _tag,
    );

    final all = await _list(api);
    for (final old in all.skip(keep)) {
      try {
        await api.files.delete(old.id);
      } catch (e, st) {
        LoggerService.warning('Could not prune ${old.name}', name: _tag);
        LoggerService.debug('$e\n$st', name: _tag);
      }
    }
    return _entry(created);
  }

  @override
  Future<List<CloudBackupEntry>> list() async => _list(await _api());

  Future<List<CloudBackupEntry>> _list(drive.DriveApi api) async {
    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name contains '$_prefix' and trashed = false",
      orderBy: 'createdTime desc',
      $fields: 'files(id, name, createdTime, size)',
    );
    return [for (final f in result.files ?? const <drive.File>[]) _entry(f)];
  }

  @override
  Future<List<int>> download(String id) async {
    final api = await _api();
    final media =
        await api.files.get(
              id,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    return media.stream.fold<List<int>>(
      <int>[],
      (acc, chunk) => acc..addAll(chunk),
    );
  }

  CloudBackupEntry _entry(drive.File f) => CloudBackupEntry(
    id: f.id ?? '',
    name: f.name ?? '',
    createdAt: (f.createdTime ?? DateTime.now()).toLocal(),
    sizeBytes: int.tryParse(f.size ?? '') ?? 0,
  );
}
