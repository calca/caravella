import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('LoggerService', () {
    test('should log debug messages correctly', () {
      // This test mainly verifies the API works without throwing
      expect(() => LoggerService.debug('Test debug message'), returnsNormally);
      expect(() => LoggerService.debug('Test debug message', name: 'test'), returnsNormally);
    });

    test('should log info messages correctly', () {
      expect(() => LoggerService.info('Test info message'), returnsNormally);
      expect(() => LoggerService.info('Test info message', name: 'test'), returnsNormally);
    });

    test('should log warning messages correctly', () {
      expect(() => LoggerService.warning('Test warning message'), returnsNormally);
      expect(() => LoggerService.warning('Test warning message', name: 'test'), returnsNormally);
    });

    test('should log error messages correctly', () {
      expect(() => LoggerService.error('Test error message'), returnsNormally);
      expect(() => LoggerService.error('Test error message', name: 'test'), returnsNormally);
    });

    test('should log error messages with error object and stack trace', () {
      final error = Exception('Test exception');
      final stackTrace = StackTrace.current;
      
      expect(
        () => LoggerService.error(
          'Test error with exception',
          name: 'test',
          error: error,
          stackTrace: stackTrace,
        ),
        returnsNormally,
      );
    });

    test('should handle different log levels with base log method', () {
      expect(() => LoggerService.log('Test message', level: LogLevel.debug), returnsNormally);
      expect(() => LoggerService.log('Test message', level: LogLevel.info), returnsNormally);
      expect(() => LoggerService.log('Test message', level: LogLevel.warning), returnsNormally);
      expect(() => LoggerService.log('Test message', level: LogLevel.error), returnsNormally);
    });

    test('should use default name when none provided', () {
      // The default name should be 'caravella'
      expect(() => LoggerService.log('Test message'), returnsNormally);
    });

    test('should handle custom names correctly', () {
      expect(() => LoggerService.log('Test message', name: 'custom.module'), returnsNormally);
      expect(() => LoggerService.log('Test message', name: 'storage.performance'), returnsNormally);
    });

    group('LogLevel enum', () {
      test('should have all expected levels', () {
        expect(LogLevel.values, contains(LogLevel.debug));
        expect(LogLevel.values, contains(LogLevel.info));
        expect(LogLevel.values, contains(LogLevel.warning));
        expect(LogLevel.values, contains(LogLevel.error));
      });

      test('should have correct number of levels', () {
        expect(LogLevel.values, hasLength(4));
      });
    });
  });
}