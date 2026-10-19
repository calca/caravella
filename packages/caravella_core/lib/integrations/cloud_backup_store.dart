/// A backup file kept in a [CloudBackupStore].
class CloudBackupEntry {
  final String id;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;

  const CloudBackupEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
  });
}

/// Where backups can be kept in the user's cloud account, an option next to
/// the file export (Google Drive in the Play build — see
/// `GmsIntegrations.createCloudBackupStore`; none in the F-Droid build).
abstract class CloudBackupStore {
  /// Shown in the UI, e.g. "Google Drive".
  String get providerName;

  /// The linked account (e.g. its email), `null` when not linked.
  String? get accountName;

  /// Restores a previous link without any UI. `true` if linked.
  Future<bool> restoreSession();

  /// Links an account (shows the provider's sign-in). `true` if linked.
  Future<bool> signIn();

  Future<void> signOut();

  /// Uploads a backup, then keeps only the newest [keep] ones.
  Future<CloudBackupEntry> upload(
    String fileName,
    List<int> bytes, {
    int keep = 5,
  });

  /// The backups kept, newest first.
  Future<List<CloudBackupEntry>> list();

  Future<List<int>> download(String id);
}
