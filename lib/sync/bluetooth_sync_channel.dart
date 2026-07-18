import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/crypto/device_key_manager.dart';
import 'package:caravella_core/sync/crypto/peer_key_store.dart';
import 'package:caravella_core/sync/crypto/sync_envelope.dart';
import 'package:caravella_core/sync/device_identity.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

/// Maximum payload size before chunking is applied (32 KB).
///
/// Not exposed as user/build configuration: no real-world payload or
/// network condition has yet required tuning it, and the Nearby Connections
/// transport itself imposes its own limits well above this. Revisit only if
/// that changes.
const int _maxChunkSize = 32 * 1024;

/// Defensive cap on the number of chunks a single reassembly may buffer
/// (~128 MB at [_maxChunkSize] each) — guards against a malformed or
/// malicious `total` value causing unbounded buffering while waiting for
/// [_chunkReassemblyTimeout] to kick in.
const int _maxChunkCount = 4096;

/// How long a partial chunk reassembly may sit in [BluetoothSyncChannel]
/// before being dropped, e.g. because the sending peer disconnected
/// mid-transfer without the transport surfacing `onDisconnected`.
const Duration _chunkReassemblyTimeout = Duration(seconds: 30);

/// How long [BluetoothSyncChannel.syncWithPeer] waits for the peer's
/// `hello_ack` before giving up.
const Duration _handshakeTimeout = Duration(seconds: 15);

/// How long [BluetoothSyncChannel.syncWithPeer] waits for the peer's sync
/// response before giving up.
const Duration _syncResponseTimeout = Duration(seconds: 30);

/// Thrown by [BluetoothSyncChannel] when the user has not granted the
/// Android runtime permissions required for Nearby Connections (Bluetooth
/// scan/connect/advertise, and nearby Wi-Fi devices on Android 13+).
///
/// Callers with UI context (e.g. [BluetoothSyncSheet]) should catch this
/// specifically to show an actionable, localized message instead of a raw
/// plugin error.
class BluetoothPermissionDeniedException implements Exception {
  const BluetoothPermissionDeniedException();

  @override
  String toString() => 'Bluetooth/nearby-device permissions were denied';
}

/// Callback invoked when a Bluetooth pairing handshake completes (on either
/// side): should persist the peer's identity and grant it access to
/// [groupId] — pairing is scoped to the specific group that was being
/// advertised, not every synced group.
typedef BluetoothPairingCallback = Future<void> Function(
  String deviceId,
  String deviceName,
  String platform,
  String groupId,
);

// ---------------------------------------------------------------------------
// Bluetooth peer events
// ---------------------------------------------------------------------------

/// Events emitted by the Bluetooth sync channel.
sealed class BluetoothPeerEvent {
  const BluetoothPeerEvent();
}

/// A nearby peer was found.
class PeerFound extends BluetoothPeerEvent {
  /// Advertised name of the peer.
  final String name;

  /// Nearby Connections endpoint ID.
  final String endpointId;

  const PeerFound({required this.name, required this.endpointId});

  @override
  String toString() => 'PeerFound(name: $name, endpointId: $endpointId)';
}

/// A previously found peer is no longer available.
class PeerLost extends BluetoothPeerEvent {
  /// Nearby Connections endpoint ID that was lost.
  final String endpointId;

  const PeerLost({required this.endpointId});

  @override
  String toString() => 'PeerLost(endpointId: $endpointId)';
}

/// Bluetooth sync started.
class BtSyncStarted extends BluetoothPeerEvent {
  const BtSyncStarted();

  @override
  String toString() => 'BtSyncStarted()';
}

/// Bluetooth sync completed successfully.
class BtSyncCompleted extends BluetoothPeerEvent {
  /// The result of the sync exchange.
  final SyncResult result;

  const BtSyncCompleted({required this.result});

  @override
  String toString() => 'BtSyncCompleted(result: $result)';
}

/// Bluetooth sync encountered an error.
class BtSyncError extends BluetoothPeerEvent {
  /// Human-readable error description.
  final String error;

  const BtSyncError({required this.error});

  @override
  String toString() => 'BtSyncError(error: $error)';
}

// ---------------------------------------------------------------------------
// Chunk envelope
// ---------------------------------------------------------------------------

/// Header for chunked payloads sent over Nearby Connections.
class _ChunkHeader {
  final int index;
  final int total;
  final String data;

  const _ChunkHeader({
    required this.index,
    required this.total,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'total': total,
        'data': data,
      };

  factory _ChunkHeader.fromJson(Map<String, dynamic> json) => _ChunkHeader(
        index: json['index'] as int,
        total: json['total'] as int,
        data: json['data'] as String,
      );
}

// ---------------------------------------------------------------------------
// BluetoothSyncChannel
// ---------------------------------------------------------------------------

/// Bluetooth / Nearby Connections sync channel.
///
/// This channel is **manual** — only activated explicitly by the user.
/// It uses the Google Nearby Connections API for peer-to-peer communication.
///
/// **Trust & encryption:** the first message on any new connection is always
/// an unencrypted `hello`/`hello_ack` handshake exchanging X25519 public
/// keys (see [DeviceKeyManager]) and the group being shared — only after
/// that does either side accept `sync` messages, which are encrypted with
/// the resulting shared key (see [SyncEnvelope]). A connection that never
/// completes the handshake has no key on file and its `sync` messages are
/// rejected — this replaces the previous behavior of auto-accepting and
/// syncing with any nearby device advertising the same service ID.
///
/// **Chunking:** If the payload exceeds 32 KB, it is split into chunks with
/// a header `{index, total, data: base64}`. Chunks are reassembled on receive.
class BluetoothSyncChannel {
  static const String _tag = 'sync.channel.bluetooth';
  static const String _channel = 'nearby';

  /// Service ID used for Nearby Connections.
  static const String serviceId = 'com.caravella.expensesync';

  final StreamController<BluetoothPeerEvent> _eventController =
      StreamController<BluetoothPeerEvent>.broadcast();

  final Nearby _nearby = Nearby();

  /// Buffers for reassembling chunked payloads, keyed by endpoint ID.
  final Map<String, List<_ChunkHeader>> _chunkBuffers = {};

  /// Per-endpoint timer that drops an incomplete [_chunkBuffers] entry after
  /// [_chunkReassemblyTimeout] — guards against a peer that disconnects
  /// mid-transfer without the transport ever calling [_onDisconnected].
  final Map<String, Timer> _chunkBufferTimers = {};

  /// Completers for pending sync responses, keyed by endpoint ID.
  final Map<String, Completer<Map<String, dynamic>>> _pendingResponses = {};

  /// Completers for a pending `hello_ack`, keyed by endpoint ID.
  final Map<String, Completer<Map<String, dynamic>>> _handshakeCompleters = {};

  bool _advertising = false;
  bool _discovering = false;

  /// The group this device is currently advertising to share, and its
  /// title — set by [startAdvertising], used when responding to an
  /// incoming `hello` to know which group to grant.
  String? _advertisingGroupId;
  String _advertisingGroupTitle = '';

  /// Callback for processing received deltas. Set before initiating sync.
  Future<Map<String, dynamic>> Function(
    Map<String, dynamic> remoteDelta,
    String peerId,
  )? onDelta;

  /// Callback invoked when a pairing handshake completes. Should persist
  /// the peer and grant it access to the group involved.
  BluetoothPairingCallback? onPairingRequest;

  /// Stream of Bluetooth peer events.
  Stream<BluetoothPeerEvent> get events => _eventController.stream;

  /// Whether currently advertising.
  bool get isAdvertising => _advertising;

  /// Whether currently discovering.
  bool get isDiscovering => _discovering;

  /// Requests the Android runtime permissions required for Nearby
  /// Connections: Bluetooth scan/connect/advertise (Android 12+) and nearby
  /// Wi-Fi devices (Android 13+).
  ///
  /// These are declared in the manifest via the `nearby_connections` and
  /// `permission_handler` plugins, but — being dangerous permissions on
  /// modern Android — still need to be requested at runtime; the
  /// `nearby_connections` plugin does not do this itself. No-ops (returns
  /// `true`) on platforms/OS versions where a given permission doesn't
  /// apply.
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      LoggerService.warning(
        'Bluetooth sync permissions not fully granted: $statuses',
        name: _tag,
      );
    }
    return allGranted;
  }

  /// Start advertising this device for nearby connections, offering to
  /// share [groupId] (titled [groupTitle]) with whoever connects.
  ///
  /// Throws [BluetoothPermissionDeniedException] if the required runtime
  /// permissions are not granted.
  Future<void> startAdvertising({
    required String groupId,
    String groupTitle = '',
  }) async {
    if (_advertising) {
      LoggerService.debug('Already advertising — skipping', name: _tag);
      return;
    }

    if (!await requestPermissions()) {
      throw const BluetoothPermissionDeniedException();
    }

    _advertisingGroupId = groupId;
    _advertisingGroupTitle = groupTitle;

    try {
      final identity = DeviceIdentity.instance;
      final started = await _nearby.startAdvertising(
        identity.deviceName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: serviceId,
      );

      if (started) {
        _advertising = true;
        LoggerService.info(
          'Started advertising as "${identity.deviceName}" for group=$groupId',
          name: _tag,
        );
      } else {
        LoggerService.warning('Advertising failed to start', name: _tag);
      }
    } catch (e, st) {
      LoggerService.error(
        'Failed to start advertising',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Start discovering nearby devices.
  ///
  /// Throws [BluetoothPermissionDeniedException] if the required runtime
  /// permissions are not granted.
  Future<void> startDiscovery() async {
    if (_discovering) {
      LoggerService.debug('Already discovering — skipping', name: _tag);
      return;
    }

    if (!await requestPermissions()) {
      throw const BluetoothPermissionDeniedException();
    }

    try {
      final started = await _nearby.startDiscovery(
        DeviceIdentity.instance.deviceName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: serviceId,
      );

      if (started) {
        _discovering = true;
        LoggerService.info('Started discovery', name: _tag);
      } else {
        LoggerService.warning('Discovery failed to start', name: _tag);
      }
    } catch (e, st) {
      LoggerService.error(
        'Failed to start discovery',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Stop all advertising and discovery.
  Future<void> stopAll() async {
    try {
      if (_advertising) {
        await _nearby.stopAdvertising();
        _advertising = false;
        _advertisingGroupId = null;
        _advertisingGroupTitle = '';
        LoggerService.info('Stopped advertising', name: _tag);
      }
      if (_discovering) {
        await _nearby.stopDiscovery();
        _discovering = false;
        LoggerService.info('Stopped discovery', name: _tag);
      }
      _chunkBuffers.clear();
      for (final timer in _chunkBufferTimers.values) {
        timer.cancel();
      }
      _chunkBufferTimers.clear();
      for (final completer in _pendingResponses.values) {
        if (!completer.isCompleted) {
          completer.complete(<String, dynamic>{});
        }
      }
      _pendingResponses.clear();
      for (final completer in _handshakeCompleters.values) {
        if (!completer.isCompleted) {
          completer.complete(<String, dynamic>{});
        }
      }
      _handshakeCompleters.clear();
    } catch (e, st) {
      LoggerService.error(
        'Error stopping Bluetooth channel',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Sync with a specific peer by endpoint ID.
  ///
  /// Connects, performs the `hello`/`hello_ack` key-exchange handshake,
  /// then exchanges encrypted deltas, and disconnects.
  Future<SyncResult> syncWithPeer(String endpointId) async {
    _eventController.add(const BtSyncStarted());

    try {
      final identity = DeviceIdentity.instance;

      // Request connection
      await _nearby.requestConnection(
        identity.deviceName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      // 1. Handshake: exchange public keys, learn & grant the shared group.
      final myPublicKey = await DeviceKeyManager.publicKeyBase64();
      final handshakeCompleter = Completer<Map<String, dynamic>>();
      _handshakeCompleters[endpointId] = handshakeCompleter;

      await _sendPayload(
        endpointId,
        jsonEncode({
          'type': 'hello',
          'device_id': identity.deviceId,
          'device_name': identity.deviceName,
          'platform': identity.platform.name,
          'public_key': myPublicKey,
        }),
      );

      final ack = await handshakeCompleter.future.timeout(
        _handshakeTimeout,
        onTimeout: () {
          LoggerService.warning(
            'Timeout waiting for handshake ack from $endpointId',
            name: _tag,
          );
          _handshakeCompleters.remove(endpointId);
          return <String, dynamic>{};
        },
      );

      final remoteDeviceId = ack['device_id'] as String?;
      final remoteDeviceName =
          ack['device_name'] as String? ?? 'Unknown device';
      final remotePlatform = ack['platform'] as String? ?? 'unknown';
      final remotePublicKey = ack['public_key'] as String?;
      final groupId = ack['group_id'] as String?;

      if (remoteDeviceId == null ||
          remotePublicKey == null ||
          groupId == null) {
        throw StateError('Bluetooth pairing handshake failed or timed out');
      }

      final sharedKey = await DeviceKeyManager.deriveSharedKey(
        remotePublicKey,
      );
      await PeerKeyStore.save(remoteDeviceId, sharedKey);
      await onPairingRequest?.call(
        remoteDeviceId,
        remoteDeviceName,
        remotePlatform,
        groupId,
      );

      // 2. Build our outgoing delta via the callback, then encrypt it.
      final localDelta = onDelta != null
          ? await onDelta!(<String, dynamic>{}, remoteDeviceId)
          : <String, dynamic>{};
      final envelope = await SyncEnvelope.encrypt(sharedKey, localDelta);

      // Register the completer before sending so a fast peer response can
      // never race ahead of us — otherwise it would be misread as a new
      // incoming sync request instead of our awaited reply.
      final completer = Completer<Map<String, dynamic>>();
      _pendingResponses[endpointId] = completer;

      await _sendPayload(
        endpointId,
        jsonEncode({
          'type': 'sync',
          'device_id': identity.deviceId,
          'envelope': envelope,
        }),
      );

      final responseJson = await completer.future.timeout(
        _syncResponseTimeout,
        onTimeout: () {
          LoggerService.warning(
            'Timeout waiting for sync response from $endpointId',
            name: _tag,
          );
          _pendingResponses.remove(endpointId);
          return <String, dynamic>{};
        },
      );

      final responseEnvelope = responseJson['envelope'] as String?;
      final remoteDelta = responseEnvelope == null
          ? <String, dynamic>{}
          : await SyncEnvelope.decrypt(sharedKey, responseEnvelope);

      // Process received delta
      if (onDelta != null && remoteDelta.isNotEmpty) {
        await onDelta!(remoteDelta, remoteDeviceId);
      }

      // Disconnect
      await _nearby.disconnectFromEndpoint(endpointId);

      final result = SyncResult(
        applied: remoteDelta.length,
        skipped: 0,
        errors: 0,
        channel: _channel,
        peerId: remoteDeviceId,
        syncedAt: DateTime.fromMillisecondsSinceEpoch(
          SyncClock.nowMs(),
          isUtc: true,
        ),
      );

      _eventController.add(BtSyncCompleted(result: result));
      LoggerService.info(
        'Sync with $remoteDeviceId completed: $result',
        name: _tag,
      );
      return result;
    } catch (e, st) {
      _pendingResponses.remove(endpointId);
      _handshakeCompleters.remove(endpointId);
      LoggerService.error(
        'Sync with $endpointId failed',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      _eventController.add(BtSyncError(error: e.toString()));
      return SyncResult(
        applied: 0,
        skipped: 0,
        errors: 1,
        channel: _channel,
        peerId: endpointId,
        syncedAt: DateTime.fromMillisecondsSinceEpoch(
          SyncClock.nowMs(),
          isUtc: true,
        ),
      );
    }
  }

  /// Dispose the channel: stops any active advertising/discovery (so Nearby
  /// Connections doesn't keep running after the caller is done with this
  /// instance) and closes the event stream.
  void dispose() {
    unawaited(stopAll());
    _eventController.close();
  }

  // ---------------------------------------------------------------------------
  // Nearby Connections callbacks
  // ---------------------------------------------------------------------------

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    LoggerService.info(
      'Connection initiated with "$endpointId" (${info.endpointName})',
      name: _tag,
    );
    // Accepting the transport-level connection is not the trust boundary —
    // it only lets us receive the `hello` handshake. Nothing is treated as
    // an authorized sync until that handshake derives a shared key (see
    // _handleHello/_handleIncomingSync).
    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: (endId, payload) =>
          _onPayloadReceived(endId, payload),
      onPayloadTransferUpdate: (endId, update) =>
          _onPayloadTransferUpdate(endId, update),
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    LoggerService.info(
      'Connection result for $endpointId: ${status.toString()}',
      name: _tag,
    );

    if (status != Status.CONNECTED) {
      // The connection never reached a usable state (rejected by the peer,
      // or a transport error) — fail any handshake/sync this endpoint was
      // waiting on immediately instead of leaving it to hit the full
      // timeout. syncWithPeer's own catch block turns this into a
      // SyncResult/BtSyncError, so no event is emitted here directly.
      LoggerService.warning(
        'Connection to $endpointId did not succeed (status=$status)',
        name: _tag,
      );
      _dropChunkBuffer(endpointId);
      final handshake = _handshakeCompleters.remove(endpointId);
      if (handshake != null && !handshake.isCompleted) {
        handshake.completeError(StateError('Connection failed: $status'));
      }
      final response = _pendingResponses.remove(endpointId);
      if (response != null && !response.isCompleted) {
        response.completeError(StateError('Connection failed: $status'));
      }
    }
  }

  void _onDisconnected(String endpointId) {
    LoggerService.info('Disconnected from $endpointId', name: _tag);
    _dropChunkBuffer(endpointId);
  }

  /// Drops any in-progress chunk reassembly for [endpointId] and cancels its
  /// [_chunkReassemblyTimeout] timer, if any.
  void _dropChunkBuffer(String endpointId) {
    _chunkBuffers.remove(endpointId);
    _chunkBufferTimers.remove(endpointId)?.cancel();
  }

  void _onEndpointFound(String endpointId, String name, String serviceId) {
    LoggerService.info(
      'Found peer: $name ($endpointId)',
      name: _tag,
    );
    _eventController.add(PeerFound(name: name, endpointId: endpointId));
  }

  void _onEndpointLost(String? endpointId) {
    if (endpointId == null) return;
    LoggerService.info('Lost peer: $endpointId', name: _tag);
    _eventController.add(PeerLost(endpointId: endpointId));
  }

  // ---------------------------------------------------------------------------
  // Payload handling
  // ---------------------------------------------------------------------------

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type != PayloadType.BYTES || payload.bytes == null) {
      LoggerService.warning(
        'Received non-bytes payload from $endpointId — ignoring',
        name: _tag,
      );
      return;
    }

    try {
      final raw = utf8.decode(payload.bytes!);
      final json = jsonDecode(raw) as Map<String, dynamic>;

      // Check if this is a chunk
      if (json.containsKey('index') && json.containsKey('total')) {
        _handleChunk(endpointId, _ChunkHeader.fromJson(json));
      } else {
        // Single (non-chunked) payload
        _handleCompletePayload(endpointId, json);
      }
    } catch (e, st) {
      LoggerService.error(
        'Error processing payload from $endpointId',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate update,
  ) {
    LoggerService.debug(
      'Payload transfer update for $endpointId: '
      '${update.bytesTransferred}/${update.totalBytes}',
      name: _tag,
    );
  }

  void _handleChunk(String endpointId, _ChunkHeader chunk) {
    if (chunk.total <= 0 || chunk.total > _maxChunkCount) {
      LoggerService.warning(
        'Rejecting chunk from $endpointId — implausible total=${chunk.total}',
        name: _tag,
      );
      return;
    }

    final isNewBuffer = !_chunkBuffers.containsKey(endpointId);
    _chunkBuffers.putIfAbsent(endpointId, () => []);
    _chunkBuffers[endpointId]!.add(chunk);

    if (isNewBuffer) {
      _chunkBufferTimers[endpointId]?.cancel();
      _chunkBufferTimers[endpointId] = Timer(_chunkReassemblyTimeout, () {
        final dropped = _chunkBuffers.remove(endpointId);
        _chunkBufferTimers.remove(endpointId);
        if (dropped != null) {
          LoggerService.warning(
            'Dropped ${dropped.length} orphaned chunk(s) from $endpointId — '
            'reassembly did not complete within $_chunkReassemblyTimeout',
            name: _tag,
          );
        }
      });
    }

    LoggerService.debug(
      'Received chunk ${chunk.index + 1}/${chunk.total} from $endpointId',
      name: _tag,
    );

    if (_chunkBuffers[endpointId]!.length == chunk.total) {
      // All chunks received — reassemble
      _chunkBufferTimers.remove(endpointId)?.cancel();
      final chunks = _chunkBuffers.remove(endpointId)!;
      chunks.sort((a, b) => a.index.compareTo(b.index));

      final reassembled = chunks.map((c) => c.data).join();
      final bytes = base64Decode(reassembled);
      final raw = utf8.decode(bytes);
      final json = jsonDecode(raw) as Map<String, dynamic>;

      LoggerService.info(
        'Reassembled ${chunks.length} chunks from $endpointId '
        '(${bytes.length} bytes)',
        name: _tag,
      );

      _handleCompletePayload(endpointId, json);
    }
  }

  void _handleCompletePayload(
    String endpointId,
    Map<String, dynamic> json,
  ) {
    final type = json['type'] as String?;

    if (type == 'hello') {
      _handleHello(endpointId, json);
      return;
    }

    if (type == 'hello_ack') {
      final completer = _handshakeCompleters.remove(endpointId);
      if (completer != null && !completer.isCompleted) {
        completer.complete(json);
      }
      return;
    }

    // 'sync' request/response — encrypted delta exchange. If there's a
    // pending completer for this endpoint, this is our awaited reply.
    final completer = _pendingResponses.remove(endpointId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(json);
      return;
    }

    // Otherwise this is an incoming sync request — respond with our delta.
    _handleIncomingSync(endpointId, json);
  }

  /// Handles an incoming `hello` from a device connecting to us while we're
  /// advertising: derives and persists the shared encryption key, grants
  /// the peer access to the group we're advertising, and replies with our
  /// own identity/public key so the peer can complete pairing on its side.
  Future<void> _handleHello(
    String endpointId,
    Map<String, dynamic> json,
  ) async {
    final peerDeviceId = json['device_id'] as String?;
    final peerDeviceName = json['device_name'] as String? ?? 'Unknown device';
    final peerPlatform = json['platform'] as String? ?? 'unknown';
    final peerPublicKey = json['public_key'] as String?;
    final groupId = _advertisingGroupId;

    if (peerDeviceId == null || peerPublicKey == null || groupId == null) {
      LoggerService.warning(
        'Rejecting Bluetooth hello from $endpointId — missing fields or '
        'not currently advertising a group',
        name: _tag,
      );
      return;
    }

    final sharedKey = await DeviceKeyManager.deriveSharedKey(peerPublicKey);
    await PeerKeyStore.save(peerDeviceId, sharedKey);
    await onPairingRequest?.call(
      peerDeviceId,
      peerDeviceName,
      peerPlatform,
      groupId,
    );
    LoggerService.info(
      'Paired with incoming device=$peerDeviceId ($peerDeviceName) '
      'for group=$groupId',
      name: _tag,
    );

    final identity = DeviceIdentity.instance;
    final myPublicKey = await DeviceKeyManager.publicKeyBase64();
    await _sendPayload(
      endpointId,
      jsonEncode({
        'type': 'hello_ack',
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'platform': identity.platform.name,
        'public_key': myPublicKey,
        'group_id': groupId,
        'group_title': _advertisingGroupTitle,
      }),
    );
  }

  Future<void> _handleIncomingSync(
    String endpointId,
    Map<String, dynamic> json,
  ) async {
    try {
      final peerId = json['device_id'] as String? ?? endpointId;
      final envelope = json['envelope'] as String?;

      final peerKey = await PeerKeyStore.get(peerId);
      if (peerKey == null || envelope == null) {
        LoggerService.warning(
          'Rejecting Bluetooth sync from $peerId — no encryption key on '
          'file (pairing handshake required)',
          name: _tag,
        );
        return;
      }

      final Map<String, dynamic> remoteDelta;
      try {
        remoteDelta = await SyncEnvelope.decrypt(peerKey, envelope);
      } catch (e) {
        LoggerService.warning(
          'Failed to decrypt Bluetooth delta from $peerId — wrong key or '
          'tampered payload',
          name: _tag,
        );
        return;
      }

      final localDelta = onDelta != null
          ? await onDelta!(remoteDelta, peerId)
          : <String, dynamic>{};
      final responseEnvelope = await SyncEnvelope.encrypt(peerKey, localDelta);

      final identity = DeviceIdentity.instance;
      final response = jsonEncode({
        'type': 'sync',
        'device_id': identity.deviceId,
        'envelope': responseEnvelope,
      });

      await _sendPayload(endpointId, response);

      // Unlike syncWithPeer (the requesting side), this is the passive
      // advertiser's side of the exchange — surface completion here too so
      // a UI showing "waiting for a device to connect" can react.
      _eventController.add(
        BtSyncCompleted(
          result: SyncResult(
            applied: remoteDelta.length,
            skipped: 0,
            errors: 0,
            channel: _channel,
            peerId: peerId,
            syncedAt: DateTime.fromMillisecondsSinceEpoch(
              SyncClock.nowMs(),
              isUtc: true,
            ),
          ),
        ),
      );
    } catch (e, st) {
      LoggerService.error(
        'Error handling incoming sync from $endpointId',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sending
  // ---------------------------------------------------------------------------

  Future<void> _sendPayload(String endpointId, String data) async {
    final bytes = utf8.encode(data);

    if (bytes.length <= _maxChunkSize) {
      // Send as single payload
      await _nearby.sendBytesPayload(
        endpointId,
        Uint8List.fromList(bytes),
      );
      LoggerService.debug(
        'Sent ${bytes.length} bytes to $endpointId',
        name: _tag,
      );
    } else {
      // Chunk and send
      final encoded = base64Encode(bytes);
      final totalChunks = (encoded.length / _maxChunkSize).ceil();

      LoggerService.info(
        'Splitting ${bytes.length} bytes into $totalChunks chunks '
        'for $endpointId',
        name: _tag,
      );

      for (var i = 0; i < totalChunks; i++) {
        final start = i * _maxChunkSize;
        final end = (start + _maxChunkSize).clamp(0, encoded.length);
        final chunkData = encoded.substring(start, end);

        final chunk = _ChunkHeader(
          index: i,
          total: totalChunks,
          data: chunkData,
        );

        final chunkBytes = utf8.encode(jsonEncode(chunk.toJson()));
        await _nearby.sendBytesPayload(
          endpointId,
          Uint8List.fromList(chunkBytes),
        );

        LoggerService.debug(
          'Sent chunk ${i + 1}/$totalChunks to $endpointId',
          name: _tag,
        );
      }
    }
  }
}
