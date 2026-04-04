import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('UserNameNotifier', () {
    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with empty name', () async {
      final notifier = UserNameNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 10));

      expect(notifier.name, isEmpty);
      expect(notifier.hasName, isFalse);
    });

    test('should save and load name', () async {
      final notifier = UserNameNotifier();

      // Set a name
      await notifier.setName('Mario');

      expect(notifier.name, equals('Mario'));
      expect(notifier.hasName, isTrue);

      // Create a new instance to test persistence
      final newNotifier = UserNameNotifier();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(newNotifier.name, equals('Mario'));
      expect(newNotifier.hasName, isTrue);
    });

    test('should trim whitespace from name', () async {
      final notifier = UserNameNotifier();

      await notifier.setName('  Mario  ');

      expect(notifier.name, equals('Mario'));
    });

    test('should handle empty name', () async {
      final notifier = UserNameNotifier();

      await notifier.setName('Mario');
      expect(notifier.hasName, isTrue);

      await notifier.setName('');
      expect(notifier.hasName, isFalse);
      expect(notifier.name, isEmpty);
    });
  });
}
