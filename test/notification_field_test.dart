import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

void main() {
  group('ExpenseGroup - notification field', () {
    test('notificationEnabled defaults to false', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: const [],
        participants: const [],
        currency: 'EUR',
      );

      expect(group.notificationEnabled, false);
    });

    test('notificationEnabled can be set to true', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: const [],
        participants: const [],
        currency: 'EUR',
        notificationEnabled: true,
      );

      expect(group.notificationEnabled, true);
    });

    test('notificationEnabled is serialized to JSON', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: const [],
        participants: const [],
        currency: 'EUR',
        notificationEnabled: true,
      );

      final json = group.toJson();
      expect(json['notificationEnabled'], true);
    });

    test('notificationEnabled is deserialized from JSON', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Group',
        'expenses': [],
        'participants': [],
        'currency': 'EUR',
        'categories': [],
        'timestamp': DateTime.now().toIso8601String(),
        'notificationEnabled': true,
      };

      final group = ExpenseGroup.fromJson(json);
      expect(group.notificationEnabled, true);
    });

    test('notificationEnabled defaults to false when not in JSON', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Group',
        'expenses': [],
        'participants': [],
        'currency': 'EUR',
        'categories': [],
        'timestamp': DateTime.now().toIso8601String(),
      };

      final group = ExpenseGroup.fromJson(json);
      expect(group.notificationEnabled, false);
    });

    test('notificationEnabled is preserved in copyWith', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: const [],
        participants: const [],
        currency: 'EUR',
        notificationEnabled: true,
      );

      final copied = group.copyWith(title: 'New Title');
      expect(copied.notificationEnabled, true);
    });

    test('notificationEnabled can be changed in copyWith', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: const [],
        participants: const [],
        currency: 'EUR',
        notificationEnabled: false,
      );

      final copied = group.copyWith(notificationEnabled: true);
      expect(copied.notificationEnabled, true);
    });
  });
}
