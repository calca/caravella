import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/storage_index.dart';

void main() {
  group('Category Autocomplete Tests', () {
    late GroupIndex groupIndex;
    late List<ExpenseGroup> testGroups;

    setUp(() {
      groupIndex = GroupIndex();
      
      // Create test data with overlapping categories
      testGroups = [
        ExpenseGroup(
          title: 'Trip 1',
          expenses: const [],
          participants: const [],
          currency: '€',
          categories: [
            ExpenseCategory(name: 'Food'),
            ExpenseCategory(name: 'Transport'),
            ExpenseCategory(name: 'Accommodation'),
          ],
        ),
        ExpenseGroup(
          title: 'Trip 2', 
          expenses: const [],
          participants: const [],
          currency: '€',
          categories: [
            ExpenseCategory(name: 'Food'), // Duplicate
            ExpenseCategory(name: 'Entertainment'),
            ExpenseCategory(name: 'Shopping'),
          ],
        ),
        ExpenseGroup(
          title: 'Trip 3',
          expenses: const [],
          participants: const [],
          currency: '€',
          categories: [
            ExpenseCategory(name: 'transport'), // Different case
            ExpenseCategory(name: 'Medical'),
          ],
        ),
      ];
      
      groupIndex.rebuild(testGroups);
    });

    test('should aggregate categories from all groups', () {
      final allCategories = groupIndex.getAllCategories();
      
      // Should have unique categories (Food appears twice but should be deduplicated)
      expect(allCategories.length, 6);
      
      final categoryNames = allCategories.map((c) => c.name.toLowerCase()).toSet();
      expect(categoryNames.contains('food'), true);
      expect(categoryNames.contains('transport'), true);
      expect(categoryNames.contains('accommodation'), true);
      expect(categoryNames.contains('entertainment'), true);
      expect(categoryNames.contains('shopping'), true);
      expect(categoryNames.contains('medical'), true);
    });

    test('should search categories case-insensitively', () {
      final results = groupIndex.searchCategories('foo');
      expect(results.length, 1);
      expect(results.first.name.toLowerCase(), 'food');
      
      final transportResults = groupIndex.searchCategories('trans');
      expect(transportResults.length, 2); // Both "Transport" and "transport"
    });

    test('should return all categories for empty query', () {
      final results = groupIndex.searchCategories('');
      expect(results.length, groupIndex.getAllCategories().length);
    });

    test('should handle non-matching search queries', () {
      final results = groupIndex.searchCategories('nonexistent');
      expect(results.length, 0);
    });

    test('should sort categories alphabetically', () {
      final allCategories = groupIndex.getAllCategories();
      final names = allCategories.map((c) => c.name.toLowerCase()).toList();
      
      // Check if sorted
      for (int i = 1; i < names.length; i++) {
        expect(names[i].compareTo(names[i-1]) >= 0, true);
      }
    });

    test('should invalidate cache when groups are updated', () {
      // Get initial categories
      final initialCategories = groupIndex.getAllCategories();
      final initialCount = initialCategories.length;
      
      // Add a new group with new categories
      final newGroup = ExpenseGroup(
        title: 'New Trip',
        expenses: const [],
        participants: const [],
        currency: '€',
        categories: [
          ExpenseCategory(name: 'NewCategory'),
        ],
      );
      
      testGroups.add(newGroup);
      groupIndex.rebuild(testGroups);
      
      // Should have more categories now
      final updatedCategories = groupIndex.getAllCategories();
      expect(updatedCategories.length, initialCount + 1);
      expect(updatedCategories.any((c) => c.name == 'NewCategory'), true);
    });
  });
}