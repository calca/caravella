import 'package:caravella_core/caravella_core.dart';

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

    final orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: repository),
      cloudChannel: CloudRelayChannel(),
    );
    await orchestrator.initialize();
    return orchestrator;
  }
}
