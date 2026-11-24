import 'dart:convert';
import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Two phones over Wi-Fi, end to end: phone A is the app's real
/// [LanSyncChannel] behind a [SyncOrchestrator] and a SQLite database
/// (without mDNS, on a free port); phone B speaks the same HTTP protocol
/// from this test, with its own id, X25519 keys and database.

ExpenseGroup _group(String id, {String title = 'Trip', int expenses = 1}) {
  final anna = ExpenseParticipant(id: '${id}_anna', name: 'Anna');
  final food = ExpenseCategory(id: '${id}_food', name: 'Food');
  return ExpenseGroup(
    id: id,
    title: title,
    currency: 'EUR',
    participants: [anna],
    categories: [food],
    expenses: [
      for (var i = 0; i < expenses; i++)
        ExpenseDetails(
          id: '${id}_e$i',
          name: 'Dinner $i',
          amount: 10.0 + i,
          paidBy: anna,
          category: food,
          date: DateTime(2026, 11, 1),
        ),
    ],
    timestamp: DateTime(2026, 11, 1),
    syncEnabled: true,
  );
}

SqliteExpenseGroupRepository _database(Directory dir, String name) =>
    SqliteExpenseGroupRepository(databasePath: '${dir.path}/$name.db');

Future<(int, Map<String, dynamic>)> _post(
  int port,
  String path,
  Map<String, dynamic> body,
) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('http://127.0.0.1:$port$path'),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    return (
      response.statusCode,
      text.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(text) as Map<String, dynamic>,
    );
  } finally {
    client.close();
  }
}

/// Phone B: pairs with phone A by its QR code (host, port, group), then
/// exchanges deltas the way [LanSyncChannel] does when it starts a sync.
class _PhoneB {
  _PhoneB(this.repo, {this.id = 'phone-b'});

  final String id;
  final SqliteExpenseGroupRepository repo;
  final _x25519 = X25519();
  late final SimpleKeyPair _keys;
  SecretKey? sharedKey;

  Future<void> init() async => _keys = await _x25519.newKeyPair();

  Future<SyncDao> get _dao async => SyncDao(await repo.database);

  /// POST /pair, as after scanning A's QR code for [groupId].
  Future<int> pair(int port, String groupId) async {
    final public = await _keys.extractPublicKey();
    final (status, body) = await _post(port, '/pair', {
      'device_id': id,
      'device_name': 'Phone B',
      'platform': 'android',
      'public_key': base64Encode(public.bytes),
      'group_id': groupId,
    });
    if (status != 200) return status;

    // Same derivation as DeviceKeyManager.deriveSharedKey.
    final secret = await _x25519.sharedSecretKey(
      keyPair: _keys,
      remotePublicKey: SimplePublicKey(
        base64Decode(body['public_key'] as String),
        type: KeyPairType.x25519,
      ),
    );
    sharedKey = await Hkdf(
      hmac: Hmac.sha256(),
      outputLength: 32,
    ).deriveKey(secretKey: secret, info: utf8.encode('caravella-sync-v1'));

    final dao = await _dao;
    await dao.addPairedDevice(
      deviceId: body['device_id'] as String,
      deviceName: body['device_name'] as String,
      platform: body['platform'] as String,
    );
    await dao.grantGroupAccess(body['device_id'] as String, groupId);
    return status;
  }

  /// One exchange started by B: its delta for A, sent encrypted to
  /// /sync/delta; A's reply applied here. Returns A's HTTP status.
  Future<int> exchange(int port, {SecretKey? key}) async {
    final db = await repo.database;
    final dao = SyncDao(db);
    final mine = await DeltaBuilder(
      syncDao: dao,
      repository: repo,
    ).buildDelta(db, 'phone-a');
    final (status, body) = await _post(port, '/sync/delta', {
      'device_id': id,
      'envelope': await SyncEnvelope.encrypt(key ?? sharedKey!, {
        ...mine,
        'device_id': id,
      }),
    });
    if (status != 200) return status;
    final reply = await SyncEnvelope.decrypt(
      sharedKey!,
      body['envelope'] as String,
    );
    final result = await ConflictResolver(
      syncDao: dao,
    ).applyDelta(db, reply, 'lan');
    expect(result.errors, 0);
    return status;
  }

  /// B as the device whose QR code A scans: an HTTP server answering
  /// /pair, /sync/ping and /sync/delta like [LanSyncChannel] does (reply
  /// built before applying A's delta). Returns the port.
  Future<int> serve() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      final json = body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(body) as Map<String, dynamic>;
      Map<String, dynamic> answer;
      switch (request.uri.path) {
        case '/pair':
          final secret = await _x25519.sharedSecretKey(
            keyPair: _keys,
            remotePublicKey: SimplePublicKey(
              base64Decode(json['public_key'] as String),
              type: KeyPairType.x25519,
            ),
          );
          sharedKey = await Hkdf(hmac: Hmac.sha256(), outputLength: 32)
              .deriveKey(
                secretKey: secret,
                info: utf8.encode('caravella-sync-v1'),
              );
          final dao = await _dao;
          await dao.addPairedDevice(
            deviceId: json['device_id'] as String,
            deviceName: json['device_name'] as String,
            platform: json['platform'] as String,
          );
          await dao.grantGroupAccess(
            json['device_id'] as String,
            json['group_id'] as String,
          );
          answer = {
            'device_id': id,
            'device_name': 'Phone B',
            'platform': 'android',
            'public_key': base64Encode((await _keys.extractPublicKey()).bytes),
          };
        case '/sync/ping':
          answer = {'device_id': id};
        default: // /sync/delta
          if (hang) return;
          if (refuse case (final status, final error)) {
            request.response
              ..statusCode = status
              ..headers.contentType = ContentType.json
              ..write(jsonEncode(error));
            await request.response.close();
            return;
          }
          final db = await repo.database;
          final dao = SyncDao(db);
          final reply = await DeltaBuilder(
            syncDao: dao,
            repository: repo,
          ).buildDelta(db, 'phone-a');
          final delta = await SyncEnvelope.decrypt(
            sharedKey!,
            json['envelope'] as String,
          );
          await ConflictResolver(syncDao: dao).applyDelta(db, delta, 'lan');
          answer = {
            'device_id': id,
            'envelope': await SyncEnvelope.encrypt(sharedKey!, {
              ...reply,
              'device_id': id,
            }),
          };
      }
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(answer));
      await request.response.close();
    });
    return _server!.port;
  }

  HttpServer? _server;

  /// How B's server answers /sync/delta: normally, never (its app frozen
  /// halfway), or with this HTTP error and body.
  bool hang = false;
  (int, Map<String, dynamic>)? refuse;

  Future<void> close() async {
    await _server?.close(force: true);
    await repo.close();
  }

  Future<ExpenseGroup?> group(String id) async =>
      (await repo.getGroupById(id)).unwrap();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The test binding answers every HttpClient request with 400; these
  // phones talk over real localhost sockets.
  HttpOverrides.global = null;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late SqliteExpenseGroupRepository phoneA;
  late LanSyncChannel lan;
  late SyncOrchestrator orchestrator;
  late _PhoneB phoneB;

  int port() => lan.port;
  Future<ExpenseGroup?> onA(String id) async =>
      (await phoneA.getGroupById(id)).unwrap();
  Future<void> later() => Future<void>.delayed(const Duration(milliseconds: 5));

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'sync_device_id': 'phone-a',
      'sync_lan_enabled': true,
    });
    FlutterSecureStorage.setMockInitialValues({});
    DeviceKeyManager.resetForTesting();
    DeviceIdentity.reset();
    await DeviceIdentity.initialize();

    dir = Directory.systemTemp.createTempSync('lan_two_peer');
    phoneA = _database(dir, 'a');
    lan = LanSyncChannel(
      port: 0,
      mdns: false,
      exchangeTimeout: const Duration(seconds: 2),
    );
    orchestrator = SyncOrchestrator(
      lanChannel: lan,
      syncManager: SyncManager(repository: phoneA),
    );
    await orchestrator.initialize();
    expect(lan.isActive, isTrue);
    // A shows the invitations B scans.
    orchestrator.openInvite('trip');
    orchestrator.openInvite('ski');

    phoneB = _PhoneB(_database(dir, 'b'));
    await phoneB.init();
    await phoneA.saveGroup(_group('trip'));
    await phoneA.saveGroup(_group('ski', title: 'Ski'));
  });

  tearDown(() async {
    await orchestrator.dispose();
    await phoneA.close();
    await phoneB.close();
    DeviceIdentity.reset();
    dir.deleteSync(recursive: true);
  });

  test(
    'pairing grants the group and the first exchange brings it to B',
    () async {
      expect(await phoneB.pair(port(), 'trip'), 200);

      final dao = SyncDao(await phoneA.database);
      expect(await dao.isPaired('phone-b'), isTrue);

      expect(await phoneB.exchange(port()), 200);
      final trip = await phoneB.group('trip');
      expect(trip?.title, 'Trip');
      expect(trip?.expenses.single.name, 'Dinner 0');
      // Only the group B paired for.
      expect(await phoneB.group('ski'), isNull);
    },
  );

  test('one exchange carries changes both ways', () async {
    await phoneB.pair(port(), 'trip');
    await phoneB.pair(port(), 'ski');
    await phoneB.exchange(port());
    await later();

    // A adds an expense to the trip, B renames the ski group.
    await phoneA.saveGroup(_group('trip', expenses: 2));
    final ski = (await phoneB.group('ski'))!;
    await phoneB.repo.saveGroup(ski.copyWith(title: 'Ski week'));
    await later();

    expect(await phoneB.exchange(port()), 200);
    expect((await phoneB.group('trip'))?.expenses, hasLength(2));
    expect((await onA('ski'))?.title, 'Ski week');
  });

  test(
    'the same group changed on both: the newer change wins on both',
    () async {
      await phoneB.pair(port(), 'trip');
      await phoneB.exchange(port());
      await later();

      await phoneA.saveGroup(_group('trip', title: 'Trip (A)'));
      await later();
      final trip = (await phoneB.group('trip'))!;
      await phoneB.repo.saveGroup(trip.copyWith(title: 'Trip (B)'));
      await later();

      await phoneB.exchange(port());
      expect((await onA('trip'))?.title, 'Trip (B)');
      expect((await phoneB.group('trip'))?.title, 'Trip (B)');
    },
  );

  test('a phone that never paired is refused', () async {
    final stranger = _PhoneB(_database(dir, 'c'), id: 'phone-c');
    await stranger.init();
    await stranger.repo.saveGroup(_group('trip', title: 'Hijacked'));
    stranger.sharedKey = await AesGcm.with256bits().newSecretKey();

    expect(await stranger.exchange(port()), HttpStatus.forbidden);
    expect((await onA('trip'))?.title, 'Trip');
    await stranger.repo.close();
  });

  test('a delta encrypted with the wrong key is refused', () async {
    await phoneB.pair(port(), 'trip');
    await phoneB.exchange(port());
    await later();
    final trip = (await phoneB.group('trip'))!;
    await phoneB.repo.saveGroup(trip.copyWith(title: 'Tampered'));

    final wrong = await AesGcm.with256bits().newSecretKey();
    expect(await phoneB.exchange(port(), key: wrong), HttpStatus.forbidden);
    expect((await onA('trip'))?.title, 'Trip');
  });

  test('after A revokes the group, nothing about it goes either way', () async {
    await phoneB.pair(port(), 'trip');
    await phoneB.exchange(port());
    await later();

    await orchestrator.revokeGroupAccess('phone-b', 'trip');
    // B's change is the newer one: only the revoked grant keeps it out.
    await phoneA.saveGroup(_group('trip', title: 'From A'));
    await later();
    final trip = (await phoneB.group('trip'))!;
    await phoneB.repo.saveGroup(trip.copyWith(title: 'From B'));
    await later();

    expect(await phoneB.exchange(port()), 200);
    expect((await onA('trip'))?.title, 'From A');
    expect((await phoneB.group('trip'))?.title, 'From B');
  });

  test('a group deleted on A is deleted on B', () async {
    await phoneB.pair(port(), 'trip');
    await phoneB.exchange(port());
    await later();

    await phoneA.deleteGroup('trip');
    await phoneB.exchange(port());
    expect(await phoneB.group('trip'), isNull);
  });

  test(
    'A scans B\'s code: pairing and the first sync bring B\'s group',
    () async {
      await phoneB.repo.saveGroup(_group('beach', title: 'Beach'));
      final bPort = await phoneB.serve();

      final synced = orchestrator.events.firstWhere((e) => e is SyncCompleted);
      expect(
        await lan.pairWithHost('127.0.0.1', bPort, groupId: 'beach'),
        isTrue,
      );
      await synced.timeout(const Duration(seconds: 10));

      expect(await SyncDao(await phoneA.database).isPaired('phone-b'), isTrue);
      expect((await onA('beach'))?.expenses.single.name, 'Dinner 0');
      // A's other groups stay on A.
      expect(await phoneB.group('trip'), isNull);
    },
  );

  group('requestLanSync', () {
    /// A paired with B by scanning B's code (B in A's peers), first sync
    /// done.
    Future<void> pairedWithServedB() async {
      await phoneB.repo.saveGroup(_group('beach', title: 'Beach'));
      final bPort = await phoneB.serve();
      final synced = orchestrator.events.firstWhere((e) => e is SyncCompleted);
      await lan.pairWithHost('127.0.0.1', bPort, groupId: 'beach');
      await synced.timeout(const Duration(seconds: 10));
    }

    Future<void> addExpenseOnA() async {
      final beach = (await onA('beach'))!;
      await phoneA.saveGroup(
        beach.copyWith(
          expenses: [
            ...beach.expenses,
            beach.expenses.first.copyWith(id: 'beach_new', name: 'Ice cream'),
          ],
        ),
      );
    }

    test('a change here reaches a known peer without Update now', () async {
      await pairedWithServedB();
      await addExpenseOnA();

      final synced = orchestrator.events.firstWhere((e) => e is SyncCompleted);
      orchestrator.requestLanSync(delay: Duration.zero);
      await synced.timeout(const Duration(seconds: 10));

      final names = (await phoneB.group('beach'))!.expenses.map((e) => e.name);
      expect(names, contains('Ice cream'));
    });

    test('requests close together make one exchange', () async {
      await pairedWithServedB();
      await addExpenseOnA();

      var exchanges = 0;
      final sub = lan.events.listen((e) {
        if (e is SyncStarted) exchanges++;
      });
      for (var i = 0; i < 3; i++) {
        orchestrator.requestLanSync(delay: const Duration(milliseconds: 50));
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await sub.cancel();

      expect(exchanges, 1);
    });

    test('with Wi-Fi sync off, nothing is exchanged', () async {
      await pairedWithServedB();
      await lan.setEnabled(false);
      await addExpenseOnA();

      var exchanges = 0;
      final sub = lan.events.listen((e) {
        if (e is SyncStarted) exchanges++;
      });
      orchestrator.requestLanSync(delay: Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await sub.cancel();

      expect(exchanges, 0);
      final names = (await phoneB.group('beach'))!.expenses.map((e) => e.name);
      expect(names, isNot(contains('Ice cream')));
    });
  });
  group('pairing only while the invitation is open', () {
    test('a group without an open invitation is refused', () async {
      expect(await phoneB.pair(port(), 'beach'), HttpStatus.forbidden);
      expect(await SyncDao(await phoneA.database).isPaired('phone-b'), isFalse);
    });

    test('closing the invitation refuses it again', () async {
      orchestrator.closeInvite('trip');
      expect(await phoneB.pair(port(), 'trip'), HttpStatus.forbidden);
    });

    test('an expired invitation is refused', () async {
      orchestrator.openInvite('trip', validFor: const Duration(seconds: -1));
      expect(orchestrator.isInviteOpen('trip'), isFalse);
      expect(await phoneB.pair(port(), 'trip'), HttpStatus.forbidden);
    });

    test('a QR code built here opens it', () async {
      orchestrator.closeInvite('trip');
      final payload = await orchestrator.buildOwnPairingPayload(
        groupId: 'trip',
        groupTitle: 'Trip',
      );
      // No Wi-Fi address on the test machine: no code, nothing opened.
      expect(orchestrator.isInviteOpen('trip'), payload != null);
    });
  });

  group('history', () {
    test('B starts: one entry on A, with what was sent and received', () async {
      await phoneB.pair(port(), 'trip');
      await phoneB.exchange(port());
      await later();

      final history = await orchestrator.getHistory();
      expect(history, hasLength(1));
      expect(history.single['channel'], 'lan');
      expect(history.single['sent'], 1); // the trip
      expect(history.single['applied'], 0);
    });

    test('A starts: one entry on A, with what was sent and received', () async {
      await phoneB.repo.saveGroup(_group('beach', title: 'Beach'));
      final bPort = await phoneB.serve();
      final synced = orchestrator.events.firstWhere((e) => e is SyncCompleted);
      await lan.pairWithHost('127.0.0.1', bPort, groupId: 'beach');
      await synced.timeout(const Duration(seconds: 10));
      await later();

      final history = await orchestrator.getHistory();
      expect(history, hasLength(1));
      expect(history.single['peerId'], 'phone-b');
      expect(history.single['applied'], 1); // the beach
      expect(history.single['sent'], 0);
    });

    test('Bluetooth exchanges are recorded as Bluetooth', () async {
      await phoneB.pair(port(), 'trip');
      final dao = SyncDao(await phoneA.database);
      await orchestrator.handleIncomingDelta({
        'schema': DeltaBuilder.schemaVersion,
        'device_id': 'phone-b',
        'timestamp': 1,
        'groups': <Object>[],
        'deleted_groups': <Object>[],
      }, 'phone-b');
      await later();
      final history = await orchestrator.getHistory();
      expect(history.single['channel'], 'bluetooth');
      expect(await dao.getLastSyncTime('phone-b'), isNotNull);
    });
  });

  group('when B misbehaves', () {
    Future<int> pairedWithServedB() async {
      await phoneB.repo.saveGroup(_group('beach', title: 'Beach'));
      final bPort = await phoneB.serve();
      final synced = orchestrator.events.firstWhere((e) => e is SyncCompleted);
      await lan.pairWithHost('127.0.0.1', bPort, groupId: 'beach');
      await synced.timeout(const Duration(seconds: 10));
      return bPort;
    }

    test('a phone that stops answering is dropped, and the next exchange '
        'still runs', () async {
      await pairedWithServedB();
      phoneB.hang = true;

      final failed = orchestrator.events.firstWhere((e) => e is SyncFailed);
      orchestrator.requestLanSync(delay: Duration.zero);
      final event = await failed.timeout(const Duration(seconds: 10));
      expect((event as SyncFailed).unreachable, isTrue);
      expect(event.peerId, 'phone-b');

      phoneB.hang = false;
      final synced = orchestrator.events.firstWhere((e) => e is SyncCompleted);
      orchestrator.requestLanSync(delay: Duration.zero);
      await synced.timeout(const Duration(seconds: 10));
    });

    test('a phone that forgot this one asks to pair again', () async {
      await pairedWithServedB();
      phoneB.refuse = (HttpStatus.forbidden, {'error': 'not_paired'});

      final failed = orchestrator.events.firstWhere((e) => e is SyncFailed);
      orchestrator.requestLanSync(delay: Duration.zero);
      final event = await failed.timeout(const Duration(seconds: 10));
      expect((event as SyncFailed).reason, SyncProblemReason.notPaired);
    });

    test('any other error is the peer\'s', () async {
      await pairedWithServedB();
      phoneB.refuse = (HttpStatus.internalServerError, {'error': 'boom'});

      final failed = orchestrator.events.firstWhere((e) => e is SyncFailed);
      orchestrator.requestLanSync(delay: Duration.zero);
      final event = await failed.timeout(const Duration(seconds: 10));
      expect((event as SyncFailed).reason, SyncProblemReason.peerError);
    });

    test('Update now exchanges with a known phone without restarting the '
        'server', () async {
      await pairedWithServedB();
      final before = lan.port;

      final synced = orchestrator.events.firstWhere(
        (e) => e is SyncCompleted && e.result.peerId == 'phone-b',
      );
      await orchestrator.triggerManualSync('lan');
      await synced.timeout(const Duration(seconds: 10));
      expect(lan.isActive, isTrue);
      expect(lan.port, before);
    });
  });

  test('the group\'s state uses the latest exchange, logged or not', () async {
    await phoneB.pair(port(), 'trip');
    await phoneB.exchange(port());
    await later();
    // B changes the trip: A's history has an entry for it.
    final trip = (await phoneB.group('trip'))!;
    await phoneB.repo.saveGroup(trip.copyWith(title: 'Trip (B)'));
    await later();
    await phoneB.exchange(port());
    expect(await orchestrator.getHistory(groupId: 'trip'), isNotEmpty);

    // Two days on, an exchange that brought nothing for the trip: only in
    // the sync log.
    final later2d = DateTime.now().add(const Duration(days: 2));
    await (await phoneA.database)
        .insert(SqliteExpenseGroupRepository.tableSyncLog, {
          'peer_id': 'phone-b',
          'channel': 'lan',
          'synced_at': later2d.millisecondsSinceEpoch,
          'delta_sent': 0,
          'delta_recv': 0,
        });
    final status = await orchestrator.getGroupSyncStatus(
      'trip',
      now: later2d.add(const Duration(hours: 1)),
    );
    expect(status.health, GroupSyncHealth.ok);
  });

  test('a port already taken: Wi-Fi sync starts on a free one', () async {
    final taken = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final other = LanSyncChannel(port: taken.port, mdns: false);
    try {
      await other.start(onDelta: (_, _, {sent}) async => {});
      expect(other.isActive, isTrue);
      expect(other.port, isNot(taken.port));
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:${other.port}/sync/ping'),
      );
      expect((await request.close()).statusCode, 200);
      client.close();
    } finally {
      await other.stop();
      other.dispose();
      await taken.close();
    }
  });
}
