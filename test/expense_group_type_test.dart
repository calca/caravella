import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseGroupType', () {
    test('has correct icons assigned', () {
      expect(ExpenseGroupType.travel.icon.codePoint, isNotNull);
      expect(ExpenseGroupType.personal.icon.codePoint, isNotNull);
      expect(ExpenseGroupType.family.icon.codePoint, isNotNull);
      expect(ExpenseGroupType.other.icon.codePoint, isNotNull);
    });

    test('has default categories for each type', () {
      expect(ExpenseGroupType.travel.defaultCategories.length, 3);
      expect(ExpenseGroupType.personal.defaultCategories.length, 3);
      expect(ExpenseGroupType.family.defaultCategories.length, 3);
      expect(ExpenseGroupType.other.defaultCategories.length, 3);
    });

    test('travel type has correct default categories', () {
      final categories = ExpenseGroupType.travel.defaultCategories;
      expect(categories, contains('Trasporti'));
      expect(categories, contains('Alloggio'));
      expect(categories, contains('Ristoranti'));
    });

    test('personal type has correct default categories', () {
      final categories = ExpenseGroupType.personal.defaultCategories;
      expect(categories, contains('Shopping'));
      expect(categories, contains('Salute'));
      expect(categories, contains('Intrattenimento'));
    });

    test('family type has correct default categories', () {
      final categories = ExpenseGroupType.family.defaultCategories;
      expect(categories, contains('Spesa'));
      expect(categories, contains('Casa'));
      expect(categories, contains('Bambini'));
    });

    test('other type has correct default categories', () {
      final categories = ExpenseGroupType.other.defaultCategories;
      expect(categories, contains('Varie'));
      expect(categories, contains('Utilità'));
      expect(categories, contains('Servizi'));
    });

    test('toJson returns correct string', () {
      expect(ExpenseGroupType.travel.toJson(), 'travel');
      expect(ExpenseGroupType.personal.toJson(), 'personal');
      expect(ExpenseGroupType.family.toJson(), 'family');
      expect(ExpenseGroupType.other.toJson(), 'other');
    });

    test('fromJson parses correctly', () {
      expect(ExpenseGroupType.fromJson('travel'), ExpenseGroupType.travel);
      expect(ExpenseGroupType.fromJson('personal'), ExpenseGroupType.personal);
      expect(ExpenseGroupType.fromJson('family'), ExpenseGroupType.family);
      expect(ExpenseGroupType.fromJson('other'), ExpenseGroupType.other);
    });

    test('fromJson returns null for invalid values', () {
      expect(ExpenseGroupType.fromJson('invalid'), isNull);
      expect(ExpenseGroupType.fromJson(null), isNull);
      expect(ExpenseGroupType.fromJson(''), isNull);
    });
  });

  group('ExpenseGroup with groupType', () {
    test('can create ExpenseGroup with groupType', () {
      final group = ExpenseGroup(
        title: 'Test Trip',
        expenses: [],
        participants: [],
        currency: '€',
        groupType: ExpenseGroupType.travel,
      );

      expect(group.groupType, ExpenseGroupType.travel);
    });

    test('groupType defaults to null when not provided', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: [],
        participants: [],
        currency: '€',
      );

      expect(group.groupType, isNull);
    });

    test('groupType serializes to JSON correctly', () {
      final group = ExpenseGroup(
        title: 'Family Trip',
        expenses: [],
        participants: [],
        currency: '€',
        groupType: ExpenseGroupType.family,
      );

      final json = group.toJson();
      expect(json['groupType'], 'family');
    });

    test('groupType deserializes from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'title': 'Personal Budget',
        'expenses': [],
        'participants': [],
        'currency': '€',
        'timestamp': DateTime.now().toIso8601String(),
        'groupType': 'personal',
      };

      final group = ExpenseGroup.fromJson(json);
      expect(group.groupType, ExpenseGroupType.personal);
    });

    test('groupType is null when not present in JSON', () {
      final json = {
        'id': 'test-id',
        'title': 'Old Group',
        'expenses': [],
        'participants': [],
        'currency': '€',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final group = ExpenseGroup.fromJson(json);
      expect(group.groupType, isNull);
    });

    test('copyWith preserves groupType', () {
      final original = ExpenseGroup(
        title: 'Original',
        expenses: [],
        participants: [],
        currency: '€',
        groupType: ExpenseGroupType.travel,
      );

      final copy = original.copyWith(title: 'Modified');
      expect(copy.groupType, ExpenseGroupType.travel);
    });

    test('copyWith can change groupType', () {
      final original = ExpenseGroup(
        title: 'Original',
        expenses: [],
        participants: [],
        currency: '€',
        groupType: ExpenseGroupType.travel,
      );

      final copy = original.copyWith(groupType: ExpenseGroupType.family);
      expect(copy.groupType, ExpenseGroupType.family);
    });

    test('copyWith can set groupType to null', () {
      final original = ExpenseGroup(
        title: 'Original',
        expenses: [],
        participants: [],
        currency: '€',
        groupType: ExpenseGroupType.travel,
      );

      final copy = original.copyWith(groupType: null);
      expect(copy.groupType, isNull);
    });
  });
}
