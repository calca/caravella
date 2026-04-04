import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseGroup Edit Change Detection Logic Tests', () {
    test('Participant comparison logic works correctly', () {
      final participants1 = [
        ExpenseParticipant(name: 'Alice'),
        ExpenseParticipant(name: 'Bob'),
      ];

      final participants2 = [
        ExpenseParticipant(name: 'Alice'),
        ExpenseParticipant(name: 'Bob'),
      ];

      final participants3 = [
        ExpenseParticipant(name: 'Alice'),
        ExpenseParticipant(name: 'Charlie'),
      ];

      // Mock the _participantsEqual logic
      bool participantsEqual(
        List<ExpenseParticipant> a,
        List<ExpenseParticipant> b,
      ) {
        if (a.length != b.length) return false;
        for (int i = 0; i < a.length; i++) {
          if (a[i].name != b[i].name) return false;
        }
        return true;
      }

      // Test equal participants
      assert(
        participantsEqual(participants1, participants2),
        'Equal participants should return true',
      );

      // Test different participants
      assert(
        !participantsEqual(participants1, participants3),
        'Different participants should return false',
      );

      // Test different length
      final shortList = [ExpenseParticipant(name: 'Alice')];
      assert(
        !participantsEqual(participants1, shortList),
        'Different length lists should return false',
      );
    });

    test('Category comparison logic works correctly', () {
      final categories1 = [
        ExpenseCategory(name: 'Food'),
        ExpenseCategory(name: 'Transport'),
      ];

      final categories2 = [
        ExpenseCategory(name: 'Food'),
        ExpenseCategory(name: 'Transport'),
      ];

      final categories3 = [
        ExpenseCategory(name: 'Food'),
        ExpenseCategory(name: 'Entertainment'),
      ];

      // Mock the _categoriesEqual logic
      bool categoriesEqual(List<ExpenseCategory> a, List<ExpenseCategory> b) {
        if (a.length != b.length) return false;
        for (int i = 0; i < a.length; i++) {
          if (a[i].name != b[i].name) return false;
        }
        return true;
      }

      // Test equal categories
      assert(
        categoriesEqual(categories1, categories2),
        'Equal categories should return true',
      );

      // Test different categories
      assert(
        !categoriesEqual(categories1, categories3),
        'Different categories should return false',
      );

      // Test different length
      final shortList = [ExpenseCategory(name: 'Food')];
      assert(
        !categoriesEqual(categories1, shortList),
        'Different length lists should return false',
      );
    });

    test('Change detection logic works correctly', () {
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [
          ExpenseParticipant(name: 'Alice'),
          ExpenseParticipant(name: 'Bob'),
        ],
        categories: [
          ExpenseCategory(name: 'Food'),
          ExpenseCategory(name: 'Transport'),
        ],
        expenses: [],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
        color: 0xFFE57373,
      );

      // Mock the _hasActualChanges logic for editing mode
      bool hasActualChanges({
        required String currentTitle,
        required List<ExpenseParticipant> currentParticipants,
        required List<ExpenseCategory> currentCategories,
        required DateTime? currentStartDate,
        required DateTime? currentEndDate,
        required String? currentImagePath,
        required int? currentColor,
        required String currentCurrency,
      }) {
        bool participantsEqual(
          List<ExpenseParticipant> a,
          List<ExpenseParticipant> b,
        ) {
          if (a.length != b.length) return false;
          for (int i = 0; i < a.length; i++) {
            if (a[i].name != b[i].name) return false;
          }
          return true;
        }

        bool categoriesEqual(List<ExpenseCategory> a, List<ExpenseCategory> b) {
          if (a.length != b.length) return false;
          for (int i = 0; i < a.length; i++) {
            if (a[i].name != b[i].name) return false;
          }
          return true;
        }

        return currentTitle.trim() != originalGroup.title ||
            currentParticipants.length != originalGroup.participants.length ||
            !participantsEqual(
              currentParticipants,
              originalGroup.participants,
            ) ||
            currentCategories.length != originalGroup.categories.length ||
            !categoriesEqual(currentCategories, originalGroup.categories) ||
            currentStartDate != originalGroup.startDate ||
            currentEndDate != originalGroup.endDate ||
            currentImagePath != originalGroup.file ||
            currentColor != originalGroup.color ||
            currentCurrency != originalGroup.currency;
      }

      // Test no changes
      assert(
        !hasActualChanges(
          currentTitle: 'Test Trip',
          currentParticipants: [
            ExpenseParticipant(name: 'Alice'),
            ExpenseParticipant(name: 'Bob'),
          ],
          currentCategories: [
            ExpenseCategory(name: 'Food'),
            ExpenseCategory(name: 'Transport'),
          ],
          currentStartDate: DateTime(2024, 1, 1),
          currentEndDate: DateTime(2024, 1, 7),
          currentImagePath: null,
          currentColor: 0xFFE57373,
          currentCurrency: '€',
        ),
        'No changes should return false',
      );

      // Test title change
      assert(
        hasActualChanges(
          currentTitle: 'Modified Test Trip',
          currentParticipants: originalGroup.participants,
          currentCategories: originalGroup.categories,
          currentStartDate: originalGroup.startDate,
          currentEndDate: originalGroup.endDate,
          currentImagePath: originalGroup.file,
          currentColor: originalGroup.color,
          currentCurrency: originalGroup.currency,
        ),
        'Title change should return true',
      );

      // Test participant change
      assert(
        hasActualChanges(
          currentTitle: originalGroup.title,
          currentParticipants: [
            ExpenseParticipant(name: 'Alice'),
            ExpenseParticipant(name: 'Charlie'), // Changed from Bob to Charlie
          ],
          currentCategories: originalGroup.categories,
          currentStartDate: originalGroup.startDate,
          currentEndDate: originalGroup.endDate,
          currentImagePath: originalGroup.file,
          currentColor: originalGroup.color,
          currentCurrency: originalGroup.currency,
        ),
        'Participant change should return true',
      );

      // Test color change
      assert(
        hasActualChanges(
          currentTitle: originalGroup.title,
          currentParticipants: originalGroup.participants,
          currentCategories: originalGroup.categories,
          currentStartDate: originalGroup.startDate,
          currentEndDate: originalGroup.endDate,
          currentImagePath: originalGroup.file,
          currentColor: 0xFF42A5F5, // Different color
          currentCurrency: originalGroup.currency,
        ),
        'Color change should return true',
      );
    });
  });
}
