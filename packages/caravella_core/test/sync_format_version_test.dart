import 'dart:convert';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// A newer app may add fields this one would drop: its sync data is refused
/// instead of stored with losses and sent back without them.
void main() {
  Map<String, dynamic> delta({Object? schema}) => {
    'schema': ?schema,
    'device_id': 'peer',
    'device_name': 'Pixel 9',
    'timestamp': 1,
    'groups': <Map<String, dynamic>>[],
    'deleted_groups': <Map<String, dynamic>>[],
  };

  group('device-to-device delta', () {
    test('this app writes version 1', () {
      expect(DeltaBuilder.schemaVersion, 1);
    });

    test('a delta without a version (2.4.0) is read as version 1', () {
      expect(DeltaBuilder.parseDelta(delta()), isNotNull);
    });

    test('a version 1 delta is read', () {
      expect(DeltaBuilder.parseDelta(delta(schema: 1)), isNotNull);
    });

    test('a delta from a newer app is refused', () {
      expect(
        () => DeltaBuilder.parseDelta(delta(schema: 2)),
        throwsA(
          isA<NewerFormatException>().having((e) => e.version, 'version', 2),
        ),
      );
    });

    test('a version that is not a number is malformed', () {
      expect(
        () => DeltaBuilder.parseDelta(delta(schema: 'two')),
        throwsFormatException,
      );
    });
  });

  group('Google Drive relay payload', () {
    String payload(int schema) => jsonEncode({
      'schema': schema,
      'device_id': 'peer',
      'device_name': 'Pixel 9',
      'exported_at': 1,
      'groups': <Map<String, dynamic>>[],
      'deleted_groups': <Map<String, dynamic>>[],
    });

    test('a version 1 payload is read', () {
      expect(GroupSerializer.deserializePayload(payload(1)), isNotNull);
    });

    test('a payload from a newer app is skipped', () {
      expect(GroupSerializer.deserializePayload(payload(2)), isNull);
    });
  });
}
