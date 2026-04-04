// Test case to verify CategoryDialog fix
// This test verifies that the addCategory method in ExpenseGroupNotifier
// properly updates the current group and persists changes.

import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseGroupNotifier addCategory', () {
    test('should add new category to current group and persist', () async {
      // Create a test group with initial categories
      final initialCategories = [
        ExpenseCategory(name: 'Food'),
        ExpenseCategory(name: 'Transport'),
      ];

      final testGroup = ExpenseGroup(
        title: 'Test Trip',
        participants: [],
        expenses: [],
        currency: 'EUR',
        categories: initialCategories,
      );

      // Create notifier and set current group
      final notifier = ExpenseGroupNotifier();
      notifier.setCurrentGroup(testGroup);

      // Add a new category
      const newCategoryName = 'Entertainment';
      await notifier.addCategory(newCategoryName);

      // Verify the category was added to the current group
      expect(notifier.currentGroup, isNotNull);
      expect(notifier.currentGroup!.categories.length, equals(3));
      expect(
        notifier.currentGroup!.categories.any((c) => c.name == newCategoryName),
        isTrue,
      );

      // Verify last added category is tracked
      expect(notifier.lastAddedCategory, equals(newCategoryName));
      expect(notifier.lastEvent, equals('category_added'));
    });

    test('should not add duplicate category', () async {
      // Create a test group with initial categories
      final initialCategories = [
        ExpenseCategory(name: 'Food'),
        ExpenseCategory(name: 'Transport'),
      ];

      final testGroup = ExpenseGroup(
        title: 'Test Trip',
        participants: [],
        expenses: [],
        currency: 'EUR',
        categories: initialCategories,
      );

      // Create notifier and set current group
      final notifier = ExpenseGroupNotifier();
      notifier.setCurrentGroup(testGroup);

      // Try to add an existing category
      await notifier.addCategory('Food');

      // Verify no duplicate was added
      expect(notifier.currentGroup!.categories.length, equals(2));
      expect(notifier.lastAddedCategory, isNull);
    });
  });
}
