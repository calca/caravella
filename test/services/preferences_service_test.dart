import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:io_caravella_egm/data/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('locale preferences', () {
      test('should return default locale when none is set', () async {
        final locale = await PreferencesService.getLocale();
        expect(locale, 'it');
      });

      test('should store and retrieve locale correctly', () async {
        await PreferencesService.setLocale('en');
        final locale = await PreferencesService.getLocale();
        expect(locale, 'en');
      });

      test('should handle different locales', () async {
        const testLocales = ['en', 'es', 'pt', 'zh'];
        
        for (final locale in testLocales) {
          await PreferencesService.setLocale(locale);
          final retrievedLocale = await PreferencesService.getLocale();
          expect(retrievedLocale, locale);
        }
      });
    });

    group('theme preferences', () {
      test('should return default theme mode when none is set', () async {
        final themeMode = await PreferencesService.getThemeMode();
        expect(themeMode, 'system');
      });

      test('should store and retrieve theme mode correctly', () async {
        await PreferencesService.setThemeMode('dark');
        final themeMode = await PreferencesService.getThemeMode();
        expect(themeMode, 'dark');
      });

      test('should handle all theme modes', () async {
        const themeModes = ['light', 'dark', 'system'];
        
        for (final mode in themeModes) {
          await PreferencesService.setThemeMode(mode);
          final retrievedMode = await PreferencesService.getThemeMode();
          expect(retrievedMode, mode);
        }
      });
    });

    group('flag secure preferences', () {
      test('should return default flag secure state when none is set', () async {
        final flagSecure = await PreferencesService.getFlagSecureEnabled();
        expect(flagSecure, true);
      });

      test('should store and retrieve flag secure state correctly', () async {
        await PreferencesService.setFlagSecureEnabled(false);
        final flagSecure = await PreferencesService.getFlagSecureEnabled();
        expect(flagSecure, false);
      });
    });

    group('user name preferences', () {
      test('should return null when no user name is set', () async {
        final userName = await PreferencesService.getUserName();
        expect(userName, null);
      });

      test('should store and retrieve user name correctly', () async {
        const testName = 'Test User';
        await PreferencesService.setUserName(testName);
        final userName = await PreferencesService.getUserName();
        expect(userName, testName);
      });

      test('should handle null user name correctly', () async {
        await PreferencesService.setUserName('Test User');
        await PreferencesService.setUserName(null);
        final userName = await PreferencesService.getUserName();
        expect(userName, null);
      });
    });

    group('auto backup preferences', () {
      test('should return default auto backup state when none is set', () async {
        final autoBackup = await PreferencesService.getAutoBackupEnabled();
        expect(autoBackup, false);
      });

      test('should store and retrieve auto backup state correctly', () async {
        await PreferencesService.setAutoBackupEnabled(true);
        final autoBackup = await PreferencesService.getAutoBackupEnabled();
        expect(autoBackup, true);
      });

      test('should return null when no last backup is set', () async {
        final lastBackup = await PreferencesService.getLastAutoBackup();
        expect(lastBackup, null);
      });

      test('should store and retrieve last backup timestamp correctly', () async {
        final testTimestamp = DateTime(2025, 1, 8, 12, 0, 0);
        await PreferencesService.setLastAutoBackup(testTimestamp);
        final lastBackup = await PreferencesService.getLastAutoBackup();
        expect(lastBackup, testTimestamp);
      });
    });

    group('utility methods', () {
      test('should check if key exists correctly', () async {
        await PreferencesService.setLocale('en');
        final hasLocale = await PreferencesService.containsKey('selected_locale');
        final hasNonExistent = await PreferencesService.containsKey('non_existent_key');
        
        expect(hasLocale, true);
        expect(hasNonExistent, false);
      });

      test('should remove specific key correctly', () async {
        await PreferencesService.setLocale('en');
        await PreferencesService.remove('selected_locale');
        final locale = await PreferencesService.getLocale();
        
        expect(locale, 'it'); // Should return default
      });

      test('should clear all preferences correctly', () async {
        await PreferencesService.setLocale('en');
        await PreferencesService.setThemeMode('dark');
        await PreferencesService.setUserName('Test User');
        
        await PreferencesService.clearAll();
        
        final locale = await PreferencesService.getLocale();
        final themeMode = await PreferencesService.getThemeMode();
        final userName = await PreferencesService.getUserName();
        
        expect(locale, 'it');
        expect(themeMode, 'system');
        expect(userName, null);
      });
    });
  });
}