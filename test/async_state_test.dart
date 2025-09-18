import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/state/async_state.dart';

void main() {
  group('AsyncValue', () {
    test('should create idle state correctly', () {
      const value = AsyncValue<String>.idle();
      
      expect(value.state, AsyncState.idle);
      expect(value.isIdle, true);
      expect(value.isLoading, false);
      expect(value.hasData, false);
      expect(value.hasError, false);
      expect(value.data, null);
      expect(value.error, null);
    });

    test('should create loading state correctly', () {
      const value = AsyncValue<String>.loading();
      
      expect(value.state, AsyncState.loading);
      expect(value.isLoading, true);
      expect(value.isIdle, false);
      expect(value.hasData, false);
      expect(value.hasError, false);
      expect(value.data, null);
      expect(value.error, null);
    });

    test('should create success state correctly', () {
      const testData = 'test data';
      const value = AsyncValue<String>.success(testData);
      
      expect(value.state, AsyncState.success);
      expect(value.hasData, true);
      expect(value.isLoading, false);
      expect(value.isIdle, false);
      expect(value.hasError, false);
      expect(value.data, testData);
      expect(value.error, null);
    });

    test('should create error state correctly', () {
      final testError = Exception('test error');
      final testStackTrace = StackTrace.current;
      final value = AsyncValue<String>.error(testError, testStackTrace);
      
      expect(value.state, AsyncState.error);
      expect(value.hasError, true);
      expect(value.isLoading, false);
      expect(value.isIdle, false);
      expect(value.hasData, false);
      expect(value.data, null);
      expect(value.error, testError);
      expect(value.stackTrace, testStackTrace);
    });

    test('should transform data correctly with map', () {
      const value = AsyncValue<int>.success(5);
      final transformed = value.map<String>((data) => 'Number: $data');
      
      expect(transformed.hasData, true);
      expect(transformed.data, 'Number: 5');
    });

    test('should handle map transformation errors', () {
      const value = AsyncValue<int>.success(5);
      final transformed = value.map<String>((data) => throw Exception('transform error'));
      
      expect(transformed.hasError, true);
      expect(transformed.error.toString(), contains('transform error'));
    });

    test('should preserve non-data states in map', () {
      const loadingValue = AsyncValue<int>.loading();
      final transformedLoading = loadingValue.map<String>((data) => 'test');
      expect(transformedLoading.isLoading, true);

      const idleValue = AsyncValue<int>.idle();
      final transformedIdle = idleValue.map<String>((data) => 'test');
      expect(transformedIdle.isIdle, true);

      final errorValue = AsyncValue<int>.error(Exception('test'), StackTrace.current);
      final transformedError = errorValue.map<String>((data) => 'test');
      expect(transformedError.hasError, true);
    });

    test('should implement equality correctly', () {
      const value1 = AsyncValue<String>.success('test');
      const value2 = AsyncValue<String>.success('test');
      const value3 = AsyncValue<String>.success('different');
      
      expect(value1, equals(value2));
      expect(value1, isNot(equals(value3)));
    });

    test('should have consistent toString representation', () {
      const idleValue = AsyncValue<String>.idle();
      expect(idleValue.toString(), 'AsyncValue.idle()');

      const loadingValue = AsyncValue<String>.loading();
      expect(loadingValue.toString(), 'AsyncValue.loading()');

      const successValue = AsyncValue<String>.success('test');
      expect(successValue.toString(), 'AsyncValue.success(test)');

      final errorValue = AsyncValue<String>.error(Exception('test'), StackTrace.current);
      expect(errorValue.toString(), contains('AsyncValue.error'));
      expect(errorValue.toString(), contains('test'));
    });
  });
}