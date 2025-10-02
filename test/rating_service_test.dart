import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RatingService Preferences', () {
    setUp(() async {
      // Initialize SharedPreferences with empty values
      SharedPreferences.setMockInitialValues({});
    });

    test('should store and retrieve total expense count', () async {
      // Arrange
      const expectedCount = 10;

      // Act
      await PreferencesService.setTotalExpenseCount(expectedCount);
      final actualCount = await PreferencesService.getTotalExpenseCount();

      // Assert
      expect(actualCount, expectedCount);
    });

    test('should return 0 for initial expense count', () async {
      // Act
      final count = await PreferencesService.getTotalExpenseCount();

      // Assert
      expect(count, 0);
    });

    test('should store and retrieve last rating prompt timestamp', () async {
      // Arrange
      final expectedTimestamp = DateTime(2024, 1, 15);

      // Act
      await PreferencesService.setLastRatingPrompt(expectedTimestamp);
      final actualTimestamp = await PreferencesService.getLastRatingPrompt();

      // Assert
      expect(actualTimestamp, isNotNull);
      expect(actualTimestamp?.year, expectedTimestamp.year);
      expect(actualTimestamp?.month, expectedTimestamp.month);
      expect(actualTimestamp?.day, expectedTimestamp.day);
    });

    test('should return null for initial last rating prompt', () async {
      // Act
      final timestamp = await PreferencesService.getLastRatingPrompt();

      // Assert
      expect(timestamp, isNull);
    });

    test('should store and retrieve has shown initial rating flag', () async {
      // Arrange & Act
      await PreferencesService.setHasShownInitialRating(true);
      final hasShown = await PreferencesService.getHasShownInitialRating();

      // Assert
      expect(hasShown, true);
    });

    test('should return false for initial has shown rating flag', () async {
      // Act
      final hasShown = await PreferencesService.getHasShownInitialRating();

      // Assert
      expect(hasShown, false);
    });

    test('should update expense count multiple times', () async {
      // Act & Assert
      await PreferencesService.setTotalExpenseCount(5);
      expect(await PreferencesService.getTotalExpenseCount(), 5);

      await PreferencesService.setTotalExpenseCount(10);
      expect(await PreferencesService.getTotalExpenseCount(), 10);

      await PreferencesService.setTotalExpenseCount(15);
      expect(await PreferencesService.getTotalExpenseCount(), 15);
    });
  });
}
