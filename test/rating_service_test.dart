import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RatingService Preferences', () {
    late PreferencesService prefs;

    setUp(() async {
      // Initialize SharedPreferences with empty values
      SharedPreferences.setMockInitialValues({});
      PreferencesService.reset();
      prefs = await PreferencesService.initialize();
    });

    test('should store and retrieve total expense count', () async {
      // Arrange
      const expectedCount = 10;

      // Act
      await prefs.storeRating.setTotalExpenseCount(expectedCount);
      final actualCount = prefs.storeRating.getTotalExpenseCount();

      // Assert
      expect(actualCount, expectedCount);
    });

    test('should return 0 for initial expense count', () {
      // Act
      final count = prefs.storeRating.getTotalExpenseCount();

      // Assert
      expect(count, 0);
    });

    test('should store and retrieve last rating prompt timestamp', () async {
      // Arrange
      final expectedTimestamp = DateTime(2024, 1, 15);

      // Act
      await prefs.storeRating.setLastPromptTime(expectedTimestamp);
      final actualTimestamp = prefs.storeRating.getLastPromptTime();

      // Assert
      expect(actualTimestamp, isNotNull);
      expect(actualTimestamp?.year, expectedTimestamp.year);
      expect(actualTimestamp?.month, expectedTimestamp.month);
      expect(actualTimestamp?.day, expectedTimestamp.day);
    });

    test('should return null for initial last rating prompt', () {
      // Act
      final timestamp = prefs.storeRating.getLastPromptTime();

      // Assert
      expect(timestamp, isNull);
    });

    test('should store and retrieve has shown initial rating flag', () async {
      // Arrange & Act
      await prefs.storeRating.setHasShownInitialPrompt(true);
      final hasShown = prefs.storeRating.hasShownInitialPrompt();

      // Assert
      expect(hasShown, true);
    });

    test('should return false for initial has shown rating flag', () {
      // Act
      final hasShown = prefs.storeRating.hasShownInitialPrompt();

      // Assert
      expect(hasShown, false);
    });

    test('should update expense count multiple times', () async {
      // Act & Assert
      await prefs.storeRating.setTotalExpenseCount(5);
      expect(prefs.storeRating.getTotalExpenseCount(), 5);

      await prefs.storeRating.setTotalExpenseCount(10);
      expect(prefs.storeRating.getTotalExpenseCount(), 10);

      await prefs.storeRating.setTotalExpenseCount(15);
      expect(prefs.storeRating.getTotalExpenseCount(), 15);
    });

    test('should increment expense count correctly', () async {
      // Arrange
      await prefs.storeRating.setTotalExpenseCount(5);

      // Act
      await prefs.storeRating.incrementExpenseCount();

      // Assert
      expect(prefs.storeRating.getTotalExpenseCount(), 6);
    });

    test('should clear last prompt time correctly', () async {
      // Arrange
      await prefs.storeRating.setLastPromptTime(DateTime.now());
      expect(prefs.storeRating.getLastPromptTime(), isNotNull);

      // Act
      await prefs.storeRating.clearLastPromptTime();

      // Assert
      expect(prefs.storeRating.getLastPromptTime(), isNull);
    });
  });
}
