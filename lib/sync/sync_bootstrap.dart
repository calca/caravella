import 'package:caravella_core/caravella_core.dart';

/// Builds the app-wide [SyncOrchestrator].
///
/// Sync works on the SQLite repository: [SyncDao] queries its sync columns
/// (`sync_enabled`, `device_id`, `updated_at`, ...). With any other
/// repository (only tests set one) this returns null and the sync UI stays
/// hidden.
class SyncBootstrap {
  static const _tag = 'sync.bootstrap';

  /// Builds and starts the [SyncOrchestrator]. Intended to be called once,
  /// from a [FutureProvider] so app startup isn't blocked on LAN/mDNS setup.
  static Future<SyncOrchestrator?> initialize() async {
    final repository = ExpenseGroupRepositoryFactory.getRepository();
    if (repository is! SqliteExpenseGroupRepository) {
      LoggerService.info(
        'Sync unavailable: not the SQLite repository',
        name: _tag,
      );
      return null;
    }

    await DeviceIdentity.initialize();

    // Google Drive cloud relay comes from caravella_gms and is only built
    // when the app is compiled with --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true
    // (see docs/GOOGLE_DRIVE_SYNC_SETUP.md) — null otherwise, and always null
    // in the F-Droid build, which hides the Cloud Sync section entirely
    // (SyncOrchestrator.isCloudEnabled).
    final orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: repository),
      cloudChannel: GmsIntegrations.instance.createCloudChannel(),
    );
    await orchestrator.initialize();
    return orchestrator;
  }
}
