import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/device_identity.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/models/sync_status.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Callback invoked when a delta is received from a peer.
/// Should process the delta and return the local delta to send back.
typedef DeltaCallback = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> remoteDelta,
  String peerId,
);

/// Callback used to check whether [peerId] has completed the QR pairing
/// handshake and is trusted for automatic sync.
typedef PeerAuthCallback = Future<bool> Function(String peerId);

/// Callback invoked when a peer completes a pairing handshake (either by
/// sending us a `/pair` request, or by us receiving a confirmation after
/// pairing with a scanned QR code). Should persist the pairing.
typedef PairingCallback = Future<void> Function(
  String deviceId,
  String deviceName,
  String platform,
);

/// LAN peer-to-peer sync channel using HTTP + mDNS (Bonsoir).
///
/// When started:
/// 1. Spins up a shelf HTTP server on a configurable port (default 8765)
/// 2. Advertises via mDNS "_caravellasync._tcp"
/// 3. Discovers other peers on the same network
/// 4. Initiates sync exchanges with discovered peers
class LanSyncChannel {
  static const String _tag = 'sync.channel.lan';
  static const String _channel = 'lan';
  static const String _prefKey = 'sync_lan_enabled';

  /// mDNS service type used for discovery and advertising.
  static const String serviceType = '_caravellasync._tcp';

  /// Default HTTP server port.
  static const int defaultPort = 8765;

  final int _port;

  HttpServer? _httpServer;
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  DeltaCallback? _onDelta;
  PeerAuthCallback? _isPeerAuthorized;
  PairingCallback? _onPairingRequest;

  final StreamController<SyncEvent> _eventController =
      StreamController<SyncEvent>.broadcast();

  /// Discovered peers keyed by device ID → (host, port).
  final Map<String, (String host, int port)> _peers = {};

  bool _active = false;

  /// Creates a [LanSyncChannel] with the given [port] (default 8765).
  LanSyncChannel({int port = defaultPort}) : _port = port;

  /// Whether the channel is currently active.
  bool get isActive => _active;

  /// The port this channel's HTTP server listens on.
  int get port => _port;

  /// Stream of sync events from this channel.
  Stream<SyncEvent> get events => _eventController.stream;

  /// Start the LAN sync channel.
  ///
  /// [onDelta] is called when a remote peer sends us a delta.
  /// The returned map is sent back as the response delta.
  ///
  /// [isPeerAuthorized], if provided, gates both inbound (`/sync/delta`
  /// requests) and outbound (mDNS-triggered auto-sync) exchanges to only
  /// peers that have completed the QR pairing handshake — unpaired peers on
  /// the same network are discovered but never synced with.
  ///
  /// [onPairingRequest], if provided, is invoked when a peer completes a
  /// pairing handshake via the `/pair` endpoint, and should persist it.
  Future<void> start({
    required DeltaCallback onDelta,
    PeerAuthCallback? isPeerAuthorized,
    PairingCallback? onPairingRequest,
  }) async {
    if (_active) {
      LoggerService.debug('LAN channel already active — skipping start', name: _tag);
      return;
    }

    _onDelta = onDelta;
    _isPeerAuthorized = isPeerAuthorized;
    _onPairingRequest = onPairingRequest;

    try {
      await _startHttpServer();
      await _startBroadcast();
      await _startDiscovery();
      _active = true;
      LoggerService.info('LAN sync channel started on port $_port', name: _tag);
    } catch (e, st) {
      LoggerService.error(
        'Failed to start LAN sync channel',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      await stop();
      rethrow;
    }
  }

  /// Stop the channel (server + discovery + broadcast).
  Future<void> stop() async {
    _active = false;
    _onDelta = null;
    _isPeerAuthorized = null;
    _onPairingRequest = null;
    _peers.clear();

    await _stopDiscovery();
    await _stopBroadcast();
    await _stopHttpServer();

    LoggerService.info('LAN sync channel stopped', name: _tag);
  }

  /// Dispose the event stream. Call when the channel will no longer be used.
  void dispose() {
    _eventController.close();
  }

  /// Whether LAN sync is enabled (user opt-in).
  ///
  /// Reads the persisted preference. Defaults to `false` — automatic local
  /// network sync stays off until the user explicitly enables it.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Enable or disable LAN sync.
  ///
  /// Persists the preference and logs the change. Does not itself start or
  /// stop the channel — callers (e.g. [SyncOrchestrator]) are responsible
  /// for reflecting the change in the running channel's lifecycle.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    LoggerService.info(
      'LAN sync ${enabled ? 'enabled' : 'disabled'}',
      name: _tag,
    );
  }

  // ---------------------------------------------------------------------------
  // HTTP Server
  // ---------------------------------------------------------------------------

  Future<void> _startHttpServer() async {
    final router = Router();

    router.post('/sync/delta', _handleDelta);
    router.get('/sync/ping', _handlePing);
    router.post('/pair', _handlePairRequest);

    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests(
          logger: (msg, isError) {
            if (isError) {
              LoggerService.error(msg, name: _tag);
            } else {
              LoggerService.debug(msg, name: _tag);
            }
          },
        ))
        .addHandler(router.call);

    _httpServer = await shelf_io.serve(handler, InternetAddress.anyIPv4, _port);
    LoggerService.info(
      'HTTP server listening on ${_httpServer!.address.address}:${_httpServer!.port}',
      name: _tag,
    );
  }

  Future<shelf.Response> _handleDelta(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final payload = jsonDecode(body) as Map<String, dynamic>;
      final remoteDelta = payload['delta'] as Map<String, dynamic>? ?? {};
      final peerId = payload['device_id'] as String? ?? 'unknown';

      LoggerService.info(
        'Received delta from peer=$peerId (${body.length} bytes)',
        name: _tag,
      );

      if (_onDelta == null) {
        return shelf.Response.internalServerError(
          body: jsonEncode({'error': 'Channel not ready'}),
          headers: {'content-type': 'application/json'},
        );
      }

      if (_isPeerAuthorized != null && !await _isPeerAuthorized!(peerId)) {
        LoggerService.warning(
          'Rejected delta from unpaired peer=$peerId',
          name: _tag,
        );
        return shelf.Response.forbidden(
          jsonEncode({'error': 'not_paired'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final responseDelta = await _onDelta!(remoteDelta, peerId);

      final identity = DeviceIdentity.instance;
      final responseBody = jsonEncode({
        'delta': responseDelta,
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'timestamp': SyncClock.nowMs(),
      });

      return shelf.Response.ok(
        responseBody,
        headers: {'content-type': 'application/json'},
      );
    } catch (e, st) {
      LoggerService.error(
        'Error handling delta request',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<shelf.Response> _handlePing(shelf.Request request) async {
    final identity = DeviceIdentity.instance;
    return shelf.Response.ok(
      jsonEncode({
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'timestamp': SyncClock.nowMs(),
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Handles an incoming pairing request from a device that scanned our QR
  /// code: persists the peer as paired, and confirms with our own identity
  /// so the caller can complete the mutual pairing on its side too.
  Future<shelf.Response> _handlePairRequest(shelf.Request request) async {
    try {
      final body = await request.readAsString();
      final payload = jsonDecode(body) as Map<String, dynamic>;
      final peerDeviceId = payload['device_id'] as String?;
      final peerDeviceName =
          payload['device_name'] as String? ?? 'Unknown device';
      final peerPlatform = payload['platform'] as String? ?? 'unknown';

      if (peerDeviceId == null) {
        return shelf.Response.badRequest(
          body: jsonEncode({'error': 'missing device_id'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await _onPairingRequest?.call(peerDeviceId, peerDeviceName, peerPlatform);
      LoggerService.info(
        'Paired with incoming device=$peerDeviceId ($peerDeviceName)',
        name: _tag,
      );

      final identity = DeviceIdentity.instance;
      return shelf.Response.ok(
        jsonEncode({
          'device_id': identity.deviceId,
          'device_name': identity.deviceName,
          'platform': identity.platform.name,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, st) {
      LoggerService.error(
        'Error handling pair request',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Sends a pairing request to [host]:[port] — typically parsed from a
  /// scanned QR code — registering this device as paired on both ends in a
  /// single round trip. Returns `true` if the handshake succeeded.
  Future<bool> pairWithHost(String host, int port) async {
    final identity = DeviceIdentity.instance;
    final client = HttpClient();
    try {
      final uri = Uri.parse('http://$host:$port/pair');
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'platform': identity.platform.name,
      }));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        LoggerService.warning(
          'Pairing with $host:$port failed: HTTP ${response.statusCode}',
          name: _tag,
        );
        return false;
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final remoteDeviceId = json['device_id'] as String?;
      final remoteDeviceName =
          json['device_name'] as String? ?? 'Unknown device';
      final remotePlatform = json['platform'] as String? ?? 'unknown';

      if (remoteDeviceId == null) return false;

      await _onPairingRequest?.call(
        remoteDeviceId,
        remoteDeviceName,
        remotePlatform,
      );
      LoggerService.info(
        'Paired with $remoteDeviceId ($remoteDeviceName) at $host:$port',
        name: _tag,
      );
      return true;
    } catch (e, st) {
      LoggerService.error(
        'Error pairing with $host:$port',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return false;
    } finally {
      client.close();
    }
  }

  Future<void> _stopHttpServer() async {
    if (_httpServer != null) {
      await _httpServer!.close(force: true);
      _httpServer = null;
      LoggerService.debug('HTTP server stopped', name: _tag);
    }
  }

  // ---------------------------------------------------------------------------
  // mDNS Broadcast
  // ---------------------------------------------------------------------------

  Future<void> _startBroadcast() async {
    final identity = DeviceIdentity.instance;
    final service = BonsoirService(
      name: identity.deviceId,
      type: serviceType,
      port: _port,
      attributes: {
        'device_name': identity.deviceName,
        'device_id': identity.deviceId,
      },
    );

    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();

    LoggerService.info(
      'mDNS broadcast started for "$serviceType" on port $_port',
      name: _tag,
    );
  }

  Future<void> _stopBroadcast() async {
    if (_broadcast != null) {
      await _broadcast!.stop();
      _broadcast = null;
      LoggerService.debug('mDNS broadcast stopped', name: _tag);
    }
  }

  // ---------------------------------------------------------------------------
  // mDNS Discovery
  // ---------------------------------------------------------------------------

  Future<void> _startDiscovery() async {
    _discovery = BonsoirDiscovery(type: serviceType);
    await _discovery!.initialize();
    await _discovery!.start();

    _discovery!.eventStream?.listen(
      _onDiscoveryEvent,
      onError: (Object e) {
        LoggerService.error('mDNS discovery error', name: _tag, error: e);
      },
    );

    LoggerService.info('mDNS discovery started for "$serviceType"', name: _tag);
  }

  Future<void> _onDiscoveryEvent(BonsoirDiscoveryEvent event) async {
    if (!_active) return;

    switch (event) {
      case BonsoirDiscoveryServiceResolvedEvent():
        await _onPeerResolved(event.service);
      case BonsoirDiscoveryServiceLostEvent():
        _onPeerLost(event.service);
      default:
        break;
    }
  }

  Future<void> _onPeerResolved(BonsoirService service) async {
    final peerId = service.attributes['device_id'] ?? service.name;
    final peerName = service.attributes['device_name'] ?? 'Unknown';
    final host = service.hostAddress;
    final port = service.port;

    // Skip self
    if (DeviceIdentity.isInitialized &&
        peerId == DeviceIdentity.instance.deviceId) {
      return;
    }

    if (host == null) {
      LoggerService.warning(
        'Resolved peer $peerId but host is null — skipping',
        name: _tag,
      );
      return;
    }

    LoggerService.info(
      'Discovered peer: $peerName ($peerId) at $host:$port',
      name: _tag,
    );

    _peers[peerId] = (host, port);
    await _syncWithPeer(peerId, host, port);
  }

  void _onPeerLost(BonsoirService service) {
    final peerId = service.attributes['device_id'] ?? service.name;
    _peers.remove(peerId);
    LoggerService.info('Peer lost: $peerId', name: _tag);
  }

  Future<void> _stopDiscovery() async {
    if (_discovery != null) {
      await _discovery!.stop();
      _discovery = null;
      LoggerService.debug('mDNS discovery stopped', name: _tag);
    }
  }

  // ---------------------------------------------------------------------------
  // Peer sync
  // ---------------------------------------------------------------------------

  Future<void> _syncWithPeer(String peerId, String host, int port) async {
    if (!_active || _onDelta == null) return;

    if (_isPeerAuthorized != null && !await _isPeerAuthorized!(peerId)) {
      LoggerService.debug(
        'Peer $peerId not paired — skipping automatic sync',
        name: _tag,
      );
      return;
    }

    _eventController.add(const SyncStarted(_channel));

    try {
      // 1. Ping to verify it's the same app
      final pingOk = await _pingPeer(host, port);
      if (!pingOk) {
        LoggerService.warning(
          'Ping failed for peer $peerId at $host:$port — skipping sync',
          name: _tag,
        );
        _eventController.add(const SyncFailed('Peer unreachable'));
        return;
      }

      // 2. Build our outgoing delta via the callback with an empty remote delta
      //    (the callback should return our local delta)
      final identity = DeviceIdentity.instance;
      final localDelta = await _onDelta!(<String, dynamic>{}, peerId);

      // 3. POST our delta to the peer
      final uri = Uri.parse('http://$host:$port/sync/delta');
      final requestBody = jsonEncode({
        'delta': localDelta,
        'device_id': identity.deviceId,
        'device_name': identity.deviceName,
        'timestamp': SyncClock.nowMs(),
      });

      final client = HttpClient();
      try {
        final httpRequest = await client.postUrl(uri);
        httpRequest.headers.contentType = ContentType.json;
        httpRequest.write(requestBody);
        final httpResponse = await httpRequest.close();

        final responseBody =
            await httpResponse.transform(utf8.decoder).join();

        if (httpResponse.statusCode == 200) {
          final responseJson =
              jsonDecode(responseBody) as Map<String, dynamic>;
          final remoteDelta =
              responseJson['delta'] as Map<String, dynamic>? ?? {};

          // 4. Process the response delta
          await _onDelta!(remoteDelta, peerId);

          final result = SyncResult(
            applied: remoteDelta.length,
            skipped: 0,
            errors: 0,
            channel: _channel,
            peerId: peerId,
            syncedAt: DateTime.fromMillisecondsSinceEpoch(
              SyncClock.nowMs(),
              isUtc: true,
            ),
          );

          _eventController.add(SyncCompleted(result));
          LoggerService.info(
            'Sync with peer $peerId completed: $result',
            name: _tag,
          );
        } else {
          LoggerService.warning(
            'Sync with peer $peerId failed: HTTP ${httpResponse.statusCode}',
            name: _tag,
          );
          _eventController.add(
            SyncFailed('HTTP ${httpResponse.statusCode}: $responseBody'),
          );
        }
      } finally {
        client.close();
      }
    } catch (e, st) {
      LoggerService.error(
        'Error syncing with peer $peerId',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      _eventController.add(SyncFailed(e.toString()));
    }
  }

  Future<bool> _pingPeer(String host, int port) async {
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse('http://$host:$port/sync/ping');
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) return false;

      final json = jsonDecode(body) as Map<String, dynamic>;
      return json.containsKey('device_id');
    } catch (e) {
      LoggerService.debug('Ping to $host:$port failed: $e', name: _tag);
      return false;
    } finally {
      client.close();
    }
  }
}
