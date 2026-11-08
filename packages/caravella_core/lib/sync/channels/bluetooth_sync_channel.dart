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
typedef BluetoothPairingCallback =
    Future<void> Function(
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
  /// Advertised name of the peer (its device name).
  final String name;

  /// Nearby Connections endpoint ID.
  final String endpointId;

  /// Title of the group the peer is inviting to, when it said (see
  /// [BluetoothEndpointName]); `null` for older versions.
  final String? groupTitle;

  /// Set when the peer is waiting for an update with an already-paired
  /// device (see [BluetoothSyncChannel.startUpdate]): its device ID, as it
  /// advertised it. `null` for an invitation.
  final String? updateDeviceId;

  const PeerFound({
    required this.name,
    required this.endpointId,
    this.groupTitle,
    this.updateDeviceId,
  });

  @override
  String toString() => 'PeerFound(name: $name, endpointId: $endpointId)';
}

/// The name a device advertises over Bluetooth.
///
/// An invitation is its device name and, after a newline, the title of the
/// group it invites to, so the joining phone can show "Pixel 9 · Invite to
/// «Lisbon»" before connecting. Older versions advertise the device name
/// alone, which decodes the same way.
///
/// An update (two paired phones refreshing each other, see
/// [BluetoothUpdate]) is the name, an empty title line and a third line
/// `upd:<deviceId>`: no group, and the other phone learns whose
/// advertisement it is without trusting the (editable) device name.
abstract final class BluetoothEndpointName {
  /// Group titles are cut to this many characters: the endpoint name must
  /// stay short.
  static const int maxGroupTitleLength = 40;

  /// Device names in an update advertisement are cut to this many
  /// characters, to leave room for the device ID.
  static const int maxUpdateNameLength = 30;

  static const String _updatePrefix = 'upd:';

  /// The name advertised while waiting for an update; [deviceId] is this
  /// phone's.
  static String encodeUpdate(String deviceName, String deviceId) {
    final name = deviceName.replaceAll('\n', ' ');
    final cut = name.length > maxUpdateNameLength
        ? '${name.substring(0, maxUpdateNameLength - 1)}…'
        : name;
    return '$cut\n\n$_updatePrefix${deviceId.replaceAll('\n', '')}';
  }

  static String encode(String deviceName, String groupTitle) {
    final name = deviceName.replaceAll('\n', ' ');
    final title = groupTitle.replaceAll('\n', ' ').trim();
    if (title.isEmpty) return name;
    final cut = title.length > maxGroupTitleLength
        ? '${title.substring(0, maxGroupTitleLength - 1)}…'
        : title;
    return '$name\n$cut';
  }

  static ({String deviceName, String? groupTitle, String? updateDeviceId})
  decode(String raw) {
    final i = raw.indexOf('\n');
    if (i < 0) return (deviceName: raw, groupTitle: null, updateDeviceId: null);
    final lines = raw.split('\n');
    if (lines.length == 3 && lines[2].startsWith(_updatePrefix)) {
      final id = lines[2].substring(_updatePrefix.length).trim();
      if (id.isNotEmpty) {
        return (deviceName: lines[0], groupTitle: null, updateDeviceId: id);
      }
    }
    final title = raw.substring(i + 1).trim();
    return (
      deviceName: raw.substring(0, i),
      groupTitle: title.isEmpty ? null : title,
      updateDeviceId: null,
    );
  }
}

/// Rules of a Bluetooth update between two already-paired phones, which
/// both run the same screen and so both advertise and discover.
abstract final class BluetoothUpdate {
  /// Whether the phone with [ownDeviceId] is the one to request the
  /// connection to [peerDeviceId]: the lexicographically smaller ID. The
  /// other side only waits, so exactly one connection is requested. Equal
  /// IDs (never in practice) make nobody initiate.
  static bool initiates(String ownDeviceId, String peerDeviceId) =>
      ownDeviceId.compareTo(peerDeviceId) < 0;

  /// How many changes (groups, deletions) an exchange's delta carries.
  static int countChanges(Map<String, dynamic> delta) {
    int length(Object? list) => list is List ? list.length : 0;
    return length(delta['groups']) + length(delta['deleted_groups']);
  }
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
  )?
  onDelta;

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

  /// Starts an update with the already-paired device [targetDeviceId]:
  /// advertises and discovers at the same time (the other phone runs the
  /// same), and only that device is served — no pairing, no group grants,
  /// and the exchange must use the key already on file for it. Any other
  /// device is ignored. See [BluetoothUpdate.initiates] for who requests
  /// the connection with [syncWithPeer].
  ///
  /// Throws [BluetoothPermissionDeniedException] if the required runtime
  /// permissions are not granted. Ended by [stopAll].
  Future<void> startUpdate({required String targetDeviceId}) =>
      throw UnsupportedError('This channel cannot update paired devices');

  /// Stop all advertising and discovery.
  Future<void> stopAll();

  /// Sync with a specific peer by endpoint ID: connect, handshake, exchange
  /// encrypted deltas, disconnect.
  Future<SyncResult> syncWithPeer(String endpointId);

  /// Stops any active advertising/discovery and closes the event stream.
  void dispose();
}
