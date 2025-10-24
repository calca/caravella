import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:io_caravella_egm/data/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService prefs;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      PreferencesService.reset();
      prefs = await PreferencesService.initialize();
    });

    group('locale preferences', () {
      test('should return default locale when none is set', () {
        final locale = prefs.locale.get();
        expect(locale, 'it');
      });

      test('should store and retrieve locale correctly', () async {
        await prefs.locale.set('en');
        final locale = prefs.locale.get();
        expect(locale, 'en');
      });

      test('should handle different locales', () async {
        const testLocales = ['en', 'es', 'pt', 'zh'];

        for (final locale in testLocales) {
          await prefs.locale.set(locale);
          final retrievedLocale = prefs.locale.get();
          expect(retrievedLocale, locale);
        }
      });
    });

    group('theme preferences', () {
      test('should return default theme mode when none is set', () {
        final themeMode = prefs.theme.get();
        expect(themeMode, 'system');
      });

      test('should store and retrieve theme mode correctly', () async {
        await prefs.theme.set('dark');
        final themeMode = prefs.theme.get();
        expect(themeMode, 'dark');
      });

      test('should handle all theme modes', () async {
        const themeModes = ['light', 'dark', 'system'];

        for (final mode in themeModes) {
          await prefs.theme.set(mode);
          final retrievedMode = prefs.theme.get();
          expect(retrievedMode, mode);
        }
      });
    });

    group('flag secure preferences', () {
      test('should return default flag secure state when none is set', () {
        final flagSecure = prefs.security.getFlagSecureEnabled();
        expect(flagSecure, true);
      });

      test('should store and retrieve flag secure state correctly', () async {
        await prefs.security.setFlagSecureEnabled(false);
        final flagSecure = prefs.security.getFlagSecureEnabled();
        expect(flagSecure, false);
      });
    });

    group('user name preferences', () {
      test('should return null when no user name is set', () {
        final userName = prefs.user.getName();
        expect(userName, null);
      });

      test('should store and retrieve user name correctly', () async {
        const testName = 'Test User';
        await prefs.user.setName(testName);
        final userName = prefs.user.getName();
        expect(userName, testName);
      });

      test('should handle null user name correctly', () async {
        await prefs.user.setName('Test User');
        await prefs.user.setName(null);
        final userName = prefs.user.getName();
        expect(userName, null);
      });
    });

    group('auto backup preferences', () {
      test('should return default auto backup state when none is set', () {
        final autoBackup = prefs.backup.isAutoBackupEnabled();
        expect(autoBackup, false);
      });

      test('should store and retrieve auto backup state correctly', () async {
        await prefs.backup.setAutoBackupEnabled(true);
        final autoBackup = prefs.backup.isAutoBackupEnabled();
        expect(autoBackup, true);
      });

      test('should return null when no last backup is set', () {
        final lastBackup = prefs.backup.getLastAutoBackupTime();
        expect(lastBackup, null);
      });

      test(
        'should store and retrieve last backup timestamp correctly',
        () async {
          final testTimestamp = DateTime(2025, 1, 8, 12, 0, 0);
          await prefs.backup.setLastAutoBackupTime(testTimestamp);
          final lastBackup = prefs.backup.getLastAutoBackupTime();
          expect(lastBackup, testTimestamp);
        },
      );
    });

    group('utility methods', () {
      test('should check if key exists correctly', () async {
        await prefs.locale.set('en');
        final hasLocale = prefs.containsKey('selected_locale');
        final hasNonExistent = prefs.containsKey('non_existent_key');

        expect(hasLocale, true);
        expect(hasNonExistent, false);
      });

      test('should remove specific key correctly', () async {
        await prefs.locale.set('en');
        await prefs.remove('selected_locale');
        final locale = prefs.locale.get();

        expect(locale, 'it'); // Should return default
      });

      test('should clear all preferences correctly', () async {
        await prefs.locale.set('en');
        await prefs.theme.set('dark');
        await prefs.user.setName('Test User');

        await prefs.clearAll();

        final locale = prefs.locale.get();
        final themeMode = prefs.theme.get();
        final userName = prefs.user.getName();

        expect(locale, 'it');
        expect(themeMode, 'system');
        expect(userName, null);
      });

      test('should get all keys correctly', () async {
        await prefs.locale.set('en');
        await prefs.theme.set('dark');

        final keys = prefs.getAllKeys();

        expect(keys.contains('selected_locale'), true);
        expect(keys.contains('theme_mode'), true);
      });
    });

    group('initialization', () {
      test(
        'should throw error when accessing instance before initialization',
        () {
          PreferencesService.reset();
          expect(() => PreferencesService.instance, throwsStateError);
        },
      );

      test('should initialize only once', () async {
        PreferencesService.reset();
        final instance1 = await PreferencesService.initialize();
        final instance2 = await PreferencesService.initialize();

        expect(identical(instance1, instance2), true);
      });
    });
  });
}
