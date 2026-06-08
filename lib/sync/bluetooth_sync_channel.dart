import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/device_identity.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';
import 'package:nearby_connections/nearby_connections.dart';

/// Maximum payload size before chunking is applied (32 KB).
const int _maxChunkSize = 32 * 1024;

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

  /// Completers for pending sync responses, keyed by endpoint ID.
  final Map<String, Completer<Map<String, dynamic>>> _pendingResponses = {};

  bool _advertising = false;
  bool _discovering = false;

  /// Callback for processing received deltas. Set before initiating sync.
  Future<Map<String, dynamic>> Function(
    Map<String, dynamic> remoteDelta,
    String peerId,
  )? onDelta;

  /// Stream of Bluetooth peer events.
  Stream<BluetoothPeerEvent> get events => _eventController.stream;

  /// Whether currently advertising.
  bool get isAdvertising => _advertising;

  /// Whether currently discovering.
  bool get isDiscovering => _discovering;

  /// Start advertising this device for nearby connections.
  Future<void> startAdvertising() async {
    if (_advertising) {
      LoggerService.debug('Already advertising — skipping', name: _tag);
      return;
    }

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

      if (started ?? false) {
        _advertising = true;
        LoggerService.info(
          'Started advertising as "${identity.deviceName}"',
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
  Future<void> startDiscovery() async {
    if (_discovering) {
      LoggerService.debug('Already discovering — skipping', name: _tag);
      return;
    }

    try {
      final started = await _nearby.startDiscovery(
        DeviceIdentity.instance.deviceName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: serviceId,
      );

      if (started ?? false) {
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
        LoggerService.info('Stopped advertising', name: _tag);
      }
      if (_discovering) {
        await _nearby.stopDiscovery();
        _discovering = false;
        LoggerService.info('Stopped discovery', name: _tag);
      }
      _chunkBuffers.clear();
      _pendingResponses.clear();
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
  /// Connects, exchanges deltas, and disconnects.
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

      // Build local delta via callback
      final localDelta = onDelta != null
          ? await onDelta!(<String, dynamic>{}, endpointId)
          : <String, dynamic>{};

      // Serialize and send
      final payload = jsonEncode({
        'delta': localDelta,
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'timestamp': SyncClock.nowMs(),
      });

      await _sendPayload(endpointId, payload);

      // Wait for response from peer
      final completer = Completer<Map<String, dynamic>>();
      _pendingResponses[endpointId] = completer;

      final remoteDelta = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          LoggerService.warning(
            'Timeout waiting for sync response from $endpointId',
            name: _tag,
          );
          return <String, dynamic>{};
        },
      );

      // Process received delta
      if (onDelta != null && remoteDelta.isNotEmpty) {
        await onDelta!(remoteDelta, endpointId);
      }

      // Disconnect
      await _nearby.disconnectFromEndpoint(endpointId);

      final result = SyncResult(
        applied: remoteDelta.length,
        skipped: 0,
        errors: 0,
        channel: _channel,
        peerId: endpointId,
        syncedAt: DateTime.fromMillisecondsSinceEpoch(
          SyncClock.nowMs(),
          isUtc: true,
        ),
      );

      _eventController.add(BtSyncCompleted(result: result));
      LoggerService.info('Sync with $endpointId completed: $result', name: _tag);
      return result;
    } catch (e, st) {
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

  /// Dispose the event stream. Call when the channel will no longer be used.
  void dispose() {
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
    // Auto-accept connections from same service
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
  }

  void _onDisconnected(String endpointId) {
    LoggerService.info('Disconnected from $endpointId', name: _tag);
    _chunkBuffers.remove(endpointId);
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
    _chunkBuffers.putIfAbsent(endpointId, () => []);
    _chunkBuffers[endpointId]!.add(chunk);

    LoggerService.debug(
      'Received chunk ${chunk.index + 1}/${chunk.total} from $endpointId',
      name: _tag,
    );

    if (_chunkBuffers[endpointId]!.length == chunk.total) {
      // All chunks received — reassemble
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
    final remoteDelta = json['delta'] as Map<String, dynamic>? ?? {};
    final peerId = json['device_id'] as String? ?? endpointId;

    // If there's a pending completer for this endpoint, resolve it
    final completer = _pendingResponses.remove(endpointId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(remoteDelta);
      return;
    }

    // Otherwise this is an incoming sync request — respond with our delta
    _handleIncomingSync(endpointId, remoteDelta, peerId);
  }

  Future<void> _handleIncomingSync(
    String endpointId,
    Map<String, dynamic> remoteDelta,
    String peerId,
  ) async {
    try {
      final localDelta = onDelta != null
          ? await onDelta!(remoteDelta, peerId)
          : <String, dynamic>{};

      final identity = DeviceIdentity.instance;
      final response = jsonEncode({
        'delta': localDelta,
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'timestamp': SyncClock.nowMs(),
      });

      await _sendPayload(endpointId, response);
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
