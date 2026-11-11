import 'dart:convert';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_gms/src/nearby_bluetooth_sync_channel.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [NearbyBluetoothSyncChannel] against a scripted phone B, through a fake
/// [Nearby] that carries bytes between them in memory: handshake, encrypted
/// exchange, chunking, reassembly limits, timeouts and updates.

const _endpoint = 'ep-b';

/// The radio: what the channel sends reaches [onMessage] (reassembled
/// when chunked); [send] and [sendChunks] deliver phone B's bytes to it.
class _Air implements Nearby {
  OnPayloadReceived? _toChannel;
  OnConnectionInitiated? _onIncoming;
  OnConnectionResult? _onIncomingResult;

  /// Every bytes payload the channel sent, as sent.
  final payloads = <Uint8List>[];

  /// Phone B's reaction to each complete message from the channel.
  void Function(Map<String, dynamic> message)? onMessage;

  final _chunks = <int, String>{};
  var _payloadId = 0;

  /// Phone B connects to the advertising channel.
  void connectFromB() {
    _onIncoming!(_endpoint, ConnectionInfo('Phone B', 'token', true));
    _onIncomingResult!(_endpoint, Status.CONNECTED);
  }

  void send(String json) => _deliver(utf8.encode(json));

  /// Sends [json] in [pieces] chunks in the channel's format (base64 of
  /// the UTF-8 bytes, split in order); [only] limits it to some of them.
  void sendChunks(String json, {int pieces = 2, Iterable<int>? only}) {
    final data = base64Encode(utf8.encode(json));
    final size = (data.length / pieces).ceil();
    for (final i in only ?? List.generate(pieces, (i) => i)) {
      final end = ((i + 1) * size).clamp(0, data.length);
      _deliver(
        utf8.encode(
          jsonEncode({
            'index': i,
            'total': pieces,
            'data': data.substring(i * size, end),
          }),
        ),
      );
    }
  }

  void _deliver(List<int> bytes) => _toChannel!(
    _endpoint,
    Payload(
      id: ++_payloadId,
      type: PayloadType.BYTES,
      bytes: Uint8List.fromList(bytes),
    ),
  );

  @override
  Future<bool> startAdvertising(
    String userNickName,
    Strategy strategy, {
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
    String serviceId = '',
  }) async {
    _onIncoming = onConnectionInitiated;
    _onIncomingResult = onConnectionResult;
    return true;
  }

  @override
  Future<bool> startDiscovery(
    String userNickName,
    Strategy strategy, {
    required OnEndpointFound onEndpointFound,
    required OnEndpointLost onEndpointLost,
    String serviceId = '',
  }) async => true;

  @override
  Future<bool> requestConnection(
    String userNickName,
    String endpointId, {
    required OnConnectionInitiated onConnectionInitiated,
    required OnConnectionResult onConnectionResult,
    required OnDisconnected onDisconnected,
  }) async {
    onConnectionInitiated(
      endpointId,
      ConnectionInfo('Phone B', 'token', false),
    );
    onConnectionResult(endpointId, Status.CONNECTED);
    return true;
  }

  @override
  Future<bool> acceptConnection(
    String endpointId, {
    required OnPayloadReceived onPayLoadRecieved,
    OnPayloadTransferUpdate? onPayloadTransferUpdate,
  }) async {
    _toChannel = onPayLoadRecieved;
    return true;
  }

  @override
  Future<void> sendBytesPayload(String endpointId, Uint8List bytes) async {
    payloads.add(bytes);
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (json.containsKey('index') && json.containsKey('total')) {
      _chunks[json['index'] as int] = json['data'] as String;
      if (_chunks.length < (json['total'] as int)) return;
      final data = [
        for (var i = 0; i < _chunks.length; i++) _chunks[i]!,
      ].join();
      _chunks.clear();
      onMessage?.call(
        jsonDecode(utf8.decode(base64Decode(data))) as Map<String, dynamic>,
      );
    } else {
      onMessage?.call(json);
    }
  }

  @override
  Future<void> stopAdvertising() async {}
  @override
  Future<void> stopDiscovery() async {}
  @override
  Future<void> disconnectFromEndpoint(String endpointId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Phone B: its own X25519 keys and the shared key once it saw the
/// channel's public key.
class _PhoneB {
  _PhoneB(this.air, {this.id = 'phone-b'});

  final _Air air;
  final String id;
  final _x25519 = X25519();
  late final SimpleKeyPair keys;
  SecretKey? sharedKey;

  Future<void> init() async => keys = await _x25519.newKeyPair();

  Future<String> publicKey() async =>
      base64Encode((await keys.extractPublicKey()).bytes);

  /// The key the channel derives for B (same as DeviceKeyManager).
  Future<SecretKey> deriveWith(String channelPublicKey) async {
    final secret = await _x25519.sharedSecretKey(
      keyPair: keys,
      remotePublicKey: SimplePublicKey(
        base64Decode(channelPublicKey),
        type: KeyPairType.x25519,
      ),
    );
    return Hkdf(
      hmac: Hmac.sha256(),
      outputLength: 32,
    ).deriveKey(secretKey: secret, info: utf8.encode('caravella-sync-v1'));
  }

  Future<String> hello({String? asId, String? publicKeyOverride}) async =>
      jsonEncode({
        'type': 'hello',
        'device_id': asId ?? id,
        'device_name': 'Phone B',
        'platform': 'android',
        'public_key': publicKeyOverride ?? await publicKey(),
      });

  Future<String> helloAck({String groupId = 'beach'}) async => jsonEncode({
    'type': 'hello_ack',
    'device_id': id,
    'device_name': 'Phone B',
    'platform': 'android',
    'public_key': await publicKey(),
    'group_id': groupId,
    'group_title': 'Beach',
  });

  Future<String> sync(Map<String, dynamic> delta) async => jsonEncode({
    'type': 'sync',
    'device_id': id,
    'envelope': await SyncEnvelope.encrypt(sharedKey!, delta),
  });

  Future<Map<String, dynamic>> open(Map<String, dynamic> message) =>
      SyncEnvelope.decrypt(sharedKey!, message['envelope'] as String);
}

/// A delta big enough to need chunks: [kb] kilobytes of expense names.
Map<String, dynamic> _delta(String from, {int kb = 1}) => {
  'schema': 2,
  'device_id': from,
  'groups': [
    {'id': 'g', 'names': 'x' * (kb * 1024)},
  ],
  'deleted_groups': <Object>[],
};

void main() {
  late _Air air;
  late _PhoneB phoneB;
  late NearbyBluetoothSyncChannel channel;
  late List<Map<String, dynamic>> received;
  late List<String> pairedFor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'sync_device_id': 'phone-a'});
    FlutterSecureStorage.setMockInitialValues({});
    DeviceKeyManager.resetForTesting();
    DeviceIdentity.reset();
    await DeviceIdentity.initialize();

    air = _Air();
    phoneB = _PhoneB(air);
    await phoneB.init();
    received = [];
    pairedFor = [];
    channel =
        NearbyBluetoothSyncChannel(
            nearby: air,
            requestPermissions: () async => true,
          )
          ..onDelta = (remote, peerId) async {
            if (remote.isNotEmpty) received.add(remote);
            return _delta('phone-a');
          }
          ..onPairingRequest = (id, name, platform, groupId) async =>
              pairedFor.add('$id:$groupId');
  });

  tearDown(() {
    channel.dispose();
    DeviceIdentity.reset();
  });

  /// B as the advertiser A connects to: acks the hello for 'beach', then
  /// answers the sync with [reply].
  void answerAsAdvertiser(Map<String, dynamic> reply) {
    air.onMessage = (message) async {
      switch (message['type']) {
        case 'hello':
          phoneB.sharedKey = await phoneB.deriveWith(
            message['public_key'] as String,
          );
          air.send(await phoneB.helloAck());
        case 'sync':
          received.add({'B got': await phoneB.open(message)});
          final answer = await phoneB.sync(reply);
          answer.length > maxNearbyBytesPayload
              ? air.sendChunks(answer, pieces: 4)
              : air.send(answer);
      }
    };
  }

  test(
    'A connects: pairs for B\'s group, sends its delta, applies B\'s',
    () async {
      answerAsAdvertiser(_delta('phone-b'));

      final result = await channel.syncWithPeer(_endpoint);

      expect(result.errors, 0);
      expect(pairedFor, ['phone-b:beach']);
      expect(received.first, {'B got': _delta('phone-a')});
      expect(received.last, _delta('phone-b'));
    },
  );

  test('over 32 KB both ways: chunks that each fit a Nearby payload', () async {
    // A sends 100 KB, B answers with 70 KB in chunks.
    channel.onDelta = (remote, peerId) async {
      if (remote.isNotEmpty) received.add(remote);
      return _delta('phone-a', kb: 100);
    };
    answerAsAdvertiser(_delta('phone-b', kb: 70));

    final result = await channel.syncWithPeer(_endpoint);

    expect(result.errors, 0);
    expect(air.payloads.length, greaterThan(2), reason: 'it was chunked');
    for (final p in air.payloads) {
      expect(p.length, lessThanOrEqualTo(maxNearbyBytesPayload));
    }
    expect(received.first, {'B got': _delta('phone-a', kb: 100)});
    expect(received.last, _delta('phone-b', kb: 70));
  });

  testWidgets('no hello_ack: the sync fails after the handshake timeout', (
    tester,
  ) async {
    air.onMessage = (_) {}; // B never answers
    late SyncResult result;
    channel.syncWithPeer(_endpoint).then((r) => result = r);

    await tester.pump(const Duration(seconds: 16));
    expect(result.errors, 1);
    expect(pairedFor, isEmpty);
  });

  testWidgets('no answer to the sync: it fails, it is not an empty success', (
    tester,
  ) async {
    air.onMessage = (message) async {
      if (message['type'] != 'hello') return; // B ignores the sync
      phoneB.sharedKey = await phoneB.deriveWith(
        message['public_key'] as String,
      );
      air.send(await phoneB.helloAck());
    };
    late SyncResult result;
    channel.syncWithPeer(_endpoint).then((r) => result = r);

    await tester.pump(const Duration(seconds: 31));
    expect(result.errors, 1);
  });

  group('A advertising, B connects', () {
    late List<Map<String, dynamic>> acks;

    setUp(() async {
      await channel.startAdvertising(groupId: 'trip', groupTitle: 'Trip');
      air.connectFromB();
      acks = [];
      air.onMessage = acks.add;
    });

    testWidgets('a chunked hello is reassembled and answered', (tester) async {
      air.sendChunks(await phoneB.hello(), pieces: 3);
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks.single['type'], 'hello_ack');
      expect(acks.single['group_id'], 'trip');
      expect(pairedFor, ['phone-b:trip']);
    });

    testWidgets('chunks that never complete are dropped after 30 s', (
      tester,
    ) async {
      final hello = await phoneB.hello();
      air.sendChunks(hello, only: [0]);
      await tester.pump(const Duration(seconds: 31));
      // The rest arrives too late: on its own it doesn't complete anything.
      air.sendChunks(hello, only: [1]);
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks, isEmpty);

      // The late piece started a buffer of its own, dropped in turn.
      await tester.pump(const Duration(seconds: 31));
      air.sendChunks(hello);
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks.single['type'], 'hello_ack');
    });

    testWidgets('a chunk with an implausible total is ignored', (tester) async {
      air.send(jsonEncode({'index': 0, 'total': 1 << 20, 'data': 'AAAA'}));
      air.send(jsonEncode({'index': 0, 'total': 0, 'data': 'AAAA'}));
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks, isEmpty);

      air.send(await phoneB.hello());
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks.single['type'], 'hello_ack');
    });

    testWidgets('B\'s sync, after the handshake, gets A\'s delta back', (
      tester,
    ) async {
      air.send(await phoneB.hello());
      await tester.pump(const Duration(milliseconds: 10));
      phoneB.sharedKey = await phoneB.deriveWith(
        acks.single['public_key'] as String,
      );

      air.send(await phoneB.sync(_delta('phone-b')));
      await tester.pump(const Duration(milliseconds: 10));
      expect(received, [_delta('phone-b')]);
      expect(await phoneB.open(acks.last), _delta('phone-a'));
    });

    testWidgets('a sync from a device that never said hello is ignored', (
      tester,
    ) async {
      phoneB.sharedKey = await AesGcm.with256bits().newSecretKey();
      air.send(await phoneB.sync(_delta('phone-b')));
      await tester.pump(const Duration(milliseconds: 10));
      expect(received, isEmpty);
      expect(acks, isEmpty);
    });
  });

  group('update with an already paired device', () {
    late List<Map<String, dynamic>> acks;

    setUp(() async {
      // Paired before: A holds the key it derived for B.
      final channelKey = await DeviceKeyManager.publicKeyBase64();
      await PeerKeyStore.save('phone-b', await phoneB.deriveWith(channelKey));
      await channel.startUpdate(targetDeviceId: 'phone-b');
      air.connectFromB();
      acks = [];
      air.onMessage = acks.add;
    });

    testWidgets('the paired device gets an update ack, no new grant', (
      tester,
    ) async {
      air.send(await phoneB.hello());
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks.single['mode'], 'update');
      expect(acks.single.containsKey('group_id'), isFalse);
      expect(pairedFor, isEmpty);
    });

    testWidgets('another device, or B\'s id with another key, gets nothing', (
      tester,
    ) async {
      final stranger = _PhoneB(air, id: 'phone-c');
      await stranger.init();
      air.send(await stranger.hello());
      air.send(
        await phoneB.hello(publicKeyOverride: await stranger.publicKey()),
      );
      await tester.pump(const Duration(milliseconds: 10));
      expect(acks, isEmpty);
    });
  });
}
