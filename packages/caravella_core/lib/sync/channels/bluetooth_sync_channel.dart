import 'package:caravella_core/sync/models/sync_result.dart';

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
// BluetoothSyncChannel
// ---------------------------------------------------------------------------

/// Peer-to-peer sync over Bluetooth / nearby Wi-Fi.
///
/// This is an **interface** — like `CloudRelayChannel`, the transport needs
/// a proprietary SDK (Google Nearby Connections), so the implementation
/// lives in the `caravella_gms` package (`NearbyBluetoothSyncChannel`) and
/// is handed out by `GmsIntegrations.createBluetoothChannel`. Builds without
/// Google Mobile Services (F-Droid) get `null` there and hide Bluetooth sync.
///
/// The channel is **manual** — only activated explicitly by the user. The
/// first message on a new connection is an unencrypted key-exchange
/// handshake; `sync` messages after it are end-to-end encrypted.
abstract class BluetoothSyncChannel {
  /// Callback for processing received deltas. Set before initiating sync.
  Future<Map<String, dynamic>> Function(
    Map<String, dynamic> remoteDelta,
    String peerId,
  )? onDelta;

  /// Callback invoked when a pairing handshake completes. Should persist
  /// the peer and grant it access to the group involved.
  BluetoothPairingCallback? onPairingRequest;

  /// Stream of Bluetooth peer events.
  Stream<BluetoothPeerEvent> get events;

  /// Whether currently advertising.
  bool get isAdvertising;

  /// Whether currently discovering.
  bool get isDiscovering;

  /// Requests the runtime permissions the transport needs. Returns `true`
  /// when they are all granted (or not applicable).
  Future<bool> requestPermissions();

  /// Start advertising this device, offering to share [groupId] (titled
  /// [groupTitle]) with whoever connects.
  ///
  /// Throws [BluetoothPermissionDeniedException] if the required runtime
  /// permissions are not granted.
  Future<void> startAdvertising({
    required String groupId,
    String groupTitle = '',
  });

  /// Start discovering nearby devices that are advertising.
  ///
  /// Throws [BluetoothPermissionDeniedException] if the required runtime
  /// permissions are not granted.
  Future<void> startDiscovery();

  /// Stop all advertising and discovery.
  Future<void> stopAll();

  /// Sync with a specific peer by endpoint ID: connect, handshake, exchange
  /// encrypted deltas, disconnect.
  Future<SyncResult> syncWithPeer(String endpointId);

  /// Stops any active advertising/discovery and closes the event stream.
  void dispose();
}
