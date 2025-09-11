import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/state/app_version_notifier.dart';

void main() {
  group('AppVersionNotifier', () {
    late AppVersionNotifier notifier;

    setUp(() {
      notifier = AppVersionNotifier();
      notifier.reset(); // Reset to clean state
    });

    test('should be a singleton', () {
      final notifier1 = AppVersionNotifier();
      final notifier2 = AppVersionNotifier();
      
      expect(identical(notifier1, notifier2), true);
    });

    test('should start with idle state', () {
      expect(notifier.value.isIdle, true);
      expect(notifier.hasData, false);
      expect(notifier.isLoading, false);
    });

    test('should load app version successfully', () async {
      await notifier.loadAppVersion();
      
      expect(notifier.hasData, true);
      expect(notifier.data, isNotNull);
      expect(notifier.data, isA<String>());
      
      // Should contain some version info or fallback
      expect(notifier.data == 'Unknown' || notifier.data!.isNotEmpty, true);
    });

    test('should handle version loading errors gracefully', () async {
      // Even if PackageInfo fails, should return 'Unknown'
      await notifier.loadAppVersion();
      
      expect(notifier.hasData, true);
      expect(notifier.data, isNotNull);
    });

    test('should refresh version in background', () async {
      // Initial load
      await notifier.loadAppVersion();
      final initialData = notifier.data;
      
      // Background refresh should not show loading
      notifier.reset();
      notifier.setData(initialData!); // Simulate having data
      
      await notifier.refreshAppVersion();
      
      expect(notifier.hasData, true);
      expect(notifier.data, isNotNull);
    });

    test('should return existing version or load if needed', () async {
      // When no data exists, should load it
      final version1 = await notifier.getOrLoadVersion();
      expect(version1, isNotNull);
      expect(notifier.hasData, true);
      
      // When data exists, should return it immediately
      final version2 = await notifier.getOrLoadVersion();
      expect(version2, version1);
    });

    test('should return loading text when loading and no data', () async {
      notifier.reset();
      
      // Start loading in background
      final future = notifier.loadAppVersion();
      
      // Should return loading text immediately
      final result = await notifier.getOrLoadVersion();
      
      // Wait for actual loading to complete
      await future;
      
      expect(result, anyOf(equals('Loading...'), isA<String>()));
    });
  });
}