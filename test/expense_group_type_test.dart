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

    test('has default category keys for each type', () {
      expect(ExpenseGroupType.travel.defaultCategoryKeys.length, 3);
      expect(ExpenseGroupType.personal.defaultCategoryKeys.length, 3);
      expect(ExpenseGroupType.family.defaultCategoryKeys.length, 3);
      expect(ExpenseGroupType.other.defaultCategoryKeys.length, 3);
    });

    test('travel type has correct default category keys', () {
      final keys = ExpenseGroupType.travel.defaultCategoryKeys;
      expect(keys, contains('category_travel_transport'));
      expect(keys, contains('category_travel_accommodation'));
      expect(keys, contains('category_travel_restaurants'));
    });

    test('personal type has correct default category keys', () {
      final keys = ExpenseGroupType.personal.defaultCategoryKeys;
      expect(keys, contains('category_personal_shopping'));
      expect(keys, contains('category_personal_health'));
      expect(keys, contains('category_personal_entertainment'));
    });

    test('family type has correct default category keys', () {
      final keys = ExpenseGroupType.family.defaultCategoryKeys;
      expect(keys, contains('category_family_groceries'));
      expect(keys, contains('category_family_home'));
      expect(keys, contains('category_family_bills'));
    });

    test('other type has correct default category keys', () {
      final keys = ExpenseGroupType.other.defaultCategoryKeys;
      expect(keys, contains('category_other_misc'));
      expect(keys, contains('category_other_utilities'));
      expect(keys, contains('category_other_services'));
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
