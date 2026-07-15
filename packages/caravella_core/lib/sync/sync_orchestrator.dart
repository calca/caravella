import 'dart:async';

import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/channels/cloud_relay_channel.dart';
import 'package:caravella_core/sync/channels/lan_sync_channel.dart';
import 'package:caravella_core/sync/device_identity.dart';
import 'package:caravella_core/sync/models/paired_device.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/models/sync_status.dart';
import 'package:caravella_core/sync/pairing_payload.dart';
import 'package:caravella_core/sync/sync_manager.dart';
import 'package:caravella_core/sync/utils/local_network_info.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Unified entry point for all sync channels.
///
/// The UI and DI container interact only with this class.
/// It manages the lifecycle of [LanSyncChannel] and [CloudRelayChannel],
/// routes incoming deltas to [SyncManager], and exposes a merged event stream.
class SyncOrchestrator {
  static const String _tag = 'sync.orchestrator';

  final LanSyncChannel _lanChannel;
  final SyncManager _syncManager;
  final CloudRelayChannel? _cloudChannel;

  final StreamController<SyncEvent> _eventController =
      StreamController<SyncEvent>.broadcast();

  /// Sync history entries (most recent first).
  final List<Map<String, dynamic>> _history = [];

  StreamSubscription<SyncEvent>? _lanEventSub;
  StreamSubscription<SyncEvent>? _managerEventSub;

  bool _initialized = false;

  /// Creates a [SyncOrchestrator] with all channel instances.
  ///
  /// [lanChannel] and [syncManager] are required.
  /// [cloudChannel] is optional — only available when cloud sync is enabled.
  SyncOrchestrator({
    required LanSyncChannel lanChannel,
    required SyncManager syncManager,
    CloudRelayChannel? cloudChannel,
  })  : _lanChannel = lanChannel,
        _syncManager = syncManager,
        _cloudChannel = cloudChannel;

  /// Whether the LAN channel is currently active.
  bool get isLanActive => _lanChannel.isActive;

  /// Whether cloud sync is enabled.
  bool get isCloudEnabled => _cloudChannel != null;

  /// The concrete cloud channel instance, or `null` if cloud sync wasn't
  /// built into this app (`ENABLE_GOOGLE_DRIVE_SYNC` not set). Exposed so
  /// UI can operate on the same, stateful instance (auth session, etc.)
  /// rather than constructing a throwaway one.
  CloudRelayChannel? get cloudChannel => _cloudChannel;

  /// Unified stream of sync events from ALL channels.
  Stream<SyncEvent> get events => _eventController.stream;

  /// Initialize: start LAN automatically, cloud if opt-in.
  ///
  /// Starts the [SyncManager], then starts the LAN channel which
  /// automatically discovers peers and begins syncing.
  /// If a [CloudRelayChannel] is provided and enabled, starts it as well.
  Future<void> initialize() async {
    if (_initialized) {
      LoggerService.debug('Orchestrator already initialized', name: _tag);
      return;
    }

    LoggerService.info('Initializing sync orchestrator', name: _tag);

    // Start the sync manager first
    await _syncManager.start();

    // Merge event streams
    _managerEventSub = _syncManager.events.listen(_forwardEvent);
    _lanEventSub = _lanChannel.events.listen(_forwardEvent);

    // Start LAN channel — automatically discovers and syncs with peers
    // that have completed the QR pairing handshake
    try {
      await _lanChannel.start(
        onDelta: _handleDelta,
        isPeerAuthorized: _syncManager.isPeerPaired,
        onPairingRequest: _syncManager.registerPairedDevice,
      );
      LoggerService.info('LAN channel started', name: _tag);
    } catch (e, st) {
      LoggerService.error(
        'Failed to start LAN channel',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }

    // Start cloud channel if available and enabled
    if (_cloudChannel != null) {
      try {
        final enabled = await _cloudChannel.isEnabled();
        if (enabled) {
          await _cloudChannel.start(
            onShards: (shards, channel) async {
              LoggerService.info(
                'Received ${shards.length} shards from cloud',
                name: _tag,
              );
            },
          );
          LoggerService.info('Cloud channel started', name: _tag);
        } else {
          LoggerService.info(
            'Cloud channel disabled — not starting',
            name: _tag,
          );
        }
      } catch (e, st) {
        LoggerService.error(
          'Failed to start cloud channel',
          name: _tag,
          error: e,
          stackTrace: st,
        );
      }
    }

    _initialized = true;
    LoggerService.info('Sync orchestrator initialized', name: _tag);
  }

  /// Dispose: stop everything and release resources.
  Future<void> dispose() async {
    LoggerService.info('Disposing sync orchestrator', name: _tag);

    await _lanEventSub?.cancel();
    await _managerEventSub?.cancel();

    await _lanChannel.stop();
    _lanChannel.dispose();

    if (_cloudChannel != null) {
      await _cloudChannel.stop();
    }

    await _syncManager.stop();
    _syncManager.dispose();

    _history.clear();
    _initialized = false;

    _eventController.close();
    LoggerService.info('Sync orchestrator disposed', name: _tag);
  }

  /// Trigger manual sync on a specific channel.
  ///
  /// Supported channel names: `"lan"`, `"cloud"`.
  /// Returns a [SyncResult] with the outcome.
  Future<SyncResult> triggerManualSync(String channelName) async {
    LoggerService.info(
      'Manual sync triggered on channel "$channelName"',
      name: _tag,
    );

    switch (channelName) {
      case 'lan':
        // Restart LAN channel to re-discover peers and sync
        if (_lanChannel.isActive) {
          await _lanChannel.stop();
        }
        await _lanChannel.start(
          onDelta: _handleDelta,
          isPeerAuthorized: _syncManager.isPeerPaired,
          onPairingRequest: _syncManager.registerPairedDevice,
        );
        // LAN sync is event-driven; return an empty result since the actual
        // sync happens asynchronously when peers are discovered.
        return SyncResult(
          applied: 0,
          skipped: 0,
          errors: 0,
          channel: 'lan',
          peerId: '',
          syncedAt: DateTime.fromMillisecondsSinceEpoch(
            SyncClock.nowMs(),
            isUtc: true,
          ),
        );

      case 'cloud':
        if (_cloudChannel == null) {
          LoggerService.warning(
            'Cloud channel not available for manual sync',
            name: _tag,
          );
          return SyncResult(
            applied: 0,
            skipped: 0,
            errors: 1,
            channel: 'cloud',
            peerId: '',
            syncedAt: DateTime.fromMillisecondsSinceEpoch(
              SyncClock.nowMs(),
              isUtc: true,
            ),
          );
        }
        return _cloudChannel.syncNow();

      default:
        LoggerService.warning(
          'Unknown channel "$channelName" for manual sync',
          name: _tag,
        );
        return SyncResult(
          applied: 0,
          skipped: 0,
          errors: 1,
          channel: channelName,
          peerId: '',
          syncedAt: DateTime.fromMillisecondsSinceEpoch(
            SyncClock.nowMs(),
            isUtc: true,
          ),
        );
    }
  }

  /// Get last N sync history entries.
  ///
  /// Each entry is a map with keys: `channel`, `peerId`, `applied`,
  /// `skipped`, `errors`, `timestamp`.
  Future<List<Map<String, dynamic>>> getHistory({int limit = 20}) async {
    if (_history.length <= limit) return List.unmodifiable(_history);
    return List.unmodifiable(_history.take(limit));
  }

  // ---------------------------------------------------------------------------
  // QR pairing
  // ---------------------------------------------------------------------------

  /// Builds this device's own pairing payload to render as a QR code for
  /// another device to scan.
  ///
  /// Returns `null` if no local network address could be resolved (e.g. no
  /// Wi-Fi connection) — pairing requires both devices on the same LAN.
  Future<PairingPayload?> buildOwnPairingPayload() async {
    final host = await LocalNetworkInfo.resolveLocalIPv4();
    if (host == null) {
      LoggerService.warning(
        'Cannot build pairing payload — no local network address',
        name: _tag,
      );
      return null;
    }

    final identity = DeviceIdentity.instance;
    return PairingPayload(
      deviceId: identity.deviceId,
      deviceName: identity.deviceName,
      platform: identity.platform.name,
      host: host,
      port: _lanChannel.port,
    );
  }

  /// Completes a pairing handshake with a device scanned from its QR code.
  /// Returns `true` if both devices now trust each other for LAN sync.
  Future<bool> pairWithScannedPayload(PairingPayload payload) =>
      _lanChannel.pairWithHost(payload.host, payload.port);

  /// Returns all devices paired for LAN sync, most recently paired first.
  Future<List<PairedDevice>> getPairedDevices() =>
      _syncManager.getPairedDevices();

  /// Revokes a pairing, removing [deviceId] from the trusted device list.
  Future<void> removePairedDevice(String deviceId) =>
      _syncManager.removePairedDevice(deviceId);

  /// Handle an incoming delta from any transport (LAN, Bluetooth, ...),
  /// routing it through [SyncManager] and returning the outgoing delta for
  /// [peerId].
  ///
  /// Exposed publicly so that transports owned outside this class — e.g. a
  /// [BluetoothSyncChannel] created per pairing session by the UI — can
  /// share the same sync pipeline as the LAN channel.
  Future<Map<String, dynamic>> handleIncomingDelta(
    Map<String, dynamic> remoteDelta,
    String peerId,
  ) =>
      _handleDelta(remoteDelta, peerId);

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Handle an incoming delta by routing it through [SyncManager].
  Future<Map<String, dynamic>> _handleDelta(
    Map<String, dynamic> remoteDelta,
    String peerId,
  ) async {
    if (remoteDelta.isNotEmpty) {
      try {
        final result =
            await _syncManager.syncWithPeer(peerId, remoteDelta, 'lan');

        _recordHistory(result);
      } catch (e, st) {
        LoggerService.error(
          'Error processing LAN delta from $peerId',
          name: _tag,
          error: e,
          stackTrace: st,
        );
      }
    }

    // Return our outgoing delta for this peer
    try {
      return await _syncManager.getOutgoingDelta(peerId);
    } catch (e, st) {
      LoggerService.error(
        'Error building outgoing delta for $peerId',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return <String, dynamic>{};
    }
  }

  void _forwardEvent(SyncEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }

    // Record completed syncs in history
    if (event is SyncCompleted) {
      _recordHistory(event.result);
    }
  }

  void _recordHistory(SyncResult result) {
    _history.insert(0, {
      'channel': result.channel,
      'peerId': result.peerId,
      'applied': result.applied,
      'skipped': result.skipped,
      'errors': result.errors,
      'timestamp': result.syncedAt.toIso8601String(),
    });

    // Cap history at 100 entries
    const maxHistory = 100;
    if (_history.length > maxHistory) {
      _history.removeRange(maxHistory, _history.length);
    }
  }
}
