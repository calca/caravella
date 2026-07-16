import 'package:caravella_core/caravella_core.dart';
import 'package:google_drive_sync/google_drive_sync.dart';

/// Builds the app-wide [SyncOrchestrator].
///
/// Sync is only available on the SQLite backend: [SyncDao] queries
/// sync-specific columns (`sync_enabled`, `device_id`, `updated_at`, ...)
/// that don't exist in the legacy JSON repository. On the JSON backend
/// (`--dart-define=USE_JSON_BACKEND=true`) this returns null and the sync
/// UI stays hidden.
class SyncBootstrap {
  static const _tag = 'sync.bootstrap';

  /// Builds and starts the [SyncOrchestrator]. Intended to be called once,
  /// from a [FutureProvider] so app startup isn't blocked on LAN/mDNS setup.
  static Future<SyncOrchestrator?> initialize() async {
    final repository = ExpenseGroupRepositoryFactory.getRepository();
    if (repository is! SqliteExpenseGroupRepository) {
      LoggerService.info('Sync unavailable on JSON backend', name: _tag);
      return null;
    }

    await DeviceIdentity.initialize();

    // Google Drive cloud relay is only built when the app is compiled with
    // --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true (see
    // docs/GOOGLE_DRIVE_SYNC_SETUP.md) — null otherwise, which hides the
    // Cloud Sync section entirely (SyncOrchestrator.isCloudEnabled).
    final orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: repository),
      cloudChannel: GoogleDriveSyncFactory.createCloudChannel(),
    );
    await orchestrator.initialize();
    return orchestrator;
  }
}
