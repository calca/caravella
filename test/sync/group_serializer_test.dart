import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GroupSerializer', () {
    ExpenseGroup makeGroup({String id = 'g1'}) {
      final participants = [
        ExpenseParticipant(name: 'Alice', id: '${id}_p0'),
        ExpenseParticipant(name: 'Bob', id: '${id}_p1'),
      ];
      final categories = [
        ExpenseCategory(name: 'Food', id: '${id}_c0'),
        ExpenseCategory(name: 'Transport', id: '${id}_c1'),
      ];
      return ExpenseGroup(
        id: id,
        title: 'Trip Rome',
        currency: 'EUR',
        participants: participants,
        categories: categories,
        expenses: [
          ExpenseDetails(
            id: '${id}_e0',
            category: categories.first,
            amount: 42.5,
            paidBy: participants.first,
            date: DateTime.utc(2024, 6, 15),
            name: 'Pizza',
            note: 'Great meal',
          ),
        ],
        timestamp: DateTime.utc(2024, 6, 1),
        startDate: DateTime.utc(2024, 6, 1),
        endDate: DateTime.utc(2024, 6, 10),
      );
    }

    test('toJson includes _sync metadata', () {
      final group = makeGroup();
      final json = GroupSerializer.toJson(
        group,
        deviceId: 'dev-1',
        updatedAt: 1000,
        syncVersion: 5,
      );

      expect(json['id'], equals('g1'));
      expect(json['title'], equals('Trip Rome'));
      expect(json['_sync'], isNotNull);
      expect(json['_sync']['device_id'], equals('dev-1'));
      expect(json['_sync']['updated_at'], equals(1000));
      expect(json['_sync']['sync_version'], equals(5));
    });

    test('fromJson round-trip preserves core fields', () {
      final original = makeGroup();
      final json = GroupSerializer.toJson(
        original,
        deviceId: 'dev-1',
        updatedAt: SyncClock.nowMs(),
        syncVersion: 1,
      );

      final restored = GroupSerializer.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.currency, equals(original.currency));
      expect(restored.participants.length, equals(original.participants.length));
      expect(restored.categories.length, equals(original.categories.length));
      expect(restored.expenses.length, equals(original.expenses.length));
    });

    test('serializePayload and deserializePayload round-trip', () {
      final group = makeGroup();
      final payload = GroupSerializer.serializePayload(
        groups: [group],
        deviceId: 'dev-1',
        deviceName: 'Test Phone',
        deletedGroups: [
          {'id': 'deleted-1', 'updated_at': 9999},
        ],
      );

      expect(payload, isA<String>());

      final parsed = GroupSerializer.deserializePayload(payload);
      expect(parsed, isNotNull);
      expect(parsed!['schema'], equals(1));
      expect(parsed['device_id'], equals('dev-1'));
      expect(parsed['device_name'], equals('Test Phone'));
      expect((parsed['groups'] as List).length, equals(1));
      expect((parsed['deleted_groups'] as List).length, equals(1));
    });

    test('deserializePayload returns null for malformed JSON', () {
      expect(GroupSerializer.deserializePayload('not json'), isNull);
      expect(GroupSerializer.deserializePayload('{}'), isNull);
      expect(GroupSerializer.deserializePayload('{"schema":1}'), isNull);
    });
  });
}
