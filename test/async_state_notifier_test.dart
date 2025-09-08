import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/state/async_state.dart';
import 'package:io_caravella_egm/state/async_state_notifier.dart';

// Test implementation of AsyncStateNotifier
class TestAsyncStateNotifier extends AsyncStateNotifier<String> {
  Future<void> loadSuccess(String data) async {
    await execute(() async => data);
  }
  
  Future<void> loadError() async {
    await execute(() async => throw Exception('Test error'));
  }
  
  Future<void> loadDelay(String data, Duration delay) async {
    await execute(() async {
      await Future.delayed(delay);
      return data;
    });
  }
  
  Future<void> loadSuccessInBackground(String data) async {
    await executeInBackground(() async => data);
  }
}

// Test implementation of AsyncListNotifier
class TestAsyncListNotifier extends AsyncListNotifier<String> {
  Future<void> loadItems(List<String> items) async {
    await execute(() async => items);
  }
}

void main() {
  group('AsyncStateNotifier', () {
    late TestAsyncStateNotifier notifier;

    setUp(() {
      notifier = TestAsyncStateNotifier();
    });

    test('should start with idle state', () {
      expect(notifier.value.isIdle, true);
      expect(notifier.isLoading, false);
      expect(notifier.hasData, false);
      expect(notifier.hasError, false);
      expect(notifier.data, null);
    });

    test('should handle successful execution', () async {
      const testData = 'test data';
      
      // Start execution
      final future = notifier.loadSuccess(testData);
      
      // Should be loading initially
      expect(notifier.isLoading, true);
      expect(notifier.hasData, false);
      
      // Wait for completion
      await future;
      
      // Should have data now
      expect(notifier.isLoading, false);
      expect(notifier.hasData, true);
      expect(notifier.data, testData);
    });

    test('should handle error execution', () async {
      // Start execution that will fail
      await notifier.loadError();
      
      // Should have error
      expect(notifier.hasError, true);
      expect(notifier.hasData, false);
      expect(notifier.isLoading, false);
      expect(notifier.value.error.toString(), contains('Test error'));
    });

    test('should notify listeners on state changes', () async {
      bool notified = false;
      notifier.addListener(() {
        notified = true;
      });
      
      await notifier.loadSuccess('test');
      
      expect(notified, true);
    });

    test('should handle background execution without loading state', () async {
      const testData = 'background data';
      
      // Execute in background
      await notifier.loadSuccessInBackground(testData);
      
      // Should have data without having shown loading
      expect(notifier.hasData, true);
      expect(notifier.data, testData);
      expect(notifier.isLoading, false);
    });

    test('should allow manual state setting', () {
      const testData = 'manual data';
      
      notifier.setData(testData);
      
      expect(notifier.hasData, true);
      expect(notifier.data, testData);
    });

    test('should allow error setting', () {
      final testError = Exception('manual error');
      final testStackTrace = StackTrace.current;
      
      notifier.setError(testError, testStackTrace);
      
      expect(notifier.hasError, true);
      expect(notifier.value.error, testError);
    });

    test('should reset to idle state', () {
      notifier.setData('test');
      expect(notifier.hasData, true);
      
      notifier.reset();
      
      expect(notifier.value.isIdle, true);
      expect(notifier.hasData, false);
    });

    test('should transform data correctly', () {
      notifier.setData('hello');
      
      notifier.transformData((data) => '$data world');
      
      expect(notifier.data, 'hello world');
    });

    test('should handle transform errors', () {
      notifier.setData('test');
      
      notifier.transformData((data) => throw Exception('transform error'));
      
      expect(notifier.hasError, true);
      expect(notifier.value.error.toString(), contains('transform error'));
    });
  });

  group('AsyncListNotifier', () {
    late TestAsyncListNotifier notifier;

    setUp(() {
      notifier = TestAsyncListNotifier();
    });

    test('should load list data correctly', () async {
      final testList = ['item1', 'item2', 'item3'];
      
      await notifier.loadItems(testList);
      
      expect(notifier.hasData, true);
      expect(notifier.data, testList);
    });

    test('should add items to existing list', () async {
      await notifier.loadItems(['item1', 'item2']);
      
      notifier.addItem('item3');
      
      expect(notifier.data, ['item1', 'item2', 'item3']);
    });

    test('should remove items from list', () async {
      await notifier.loadItems(['item1', 'item2', 'item3']);
      
      notifier.removeItem('item2');
      
      expect(notifier.data, ['item1', 'item3']);
    });

    test('should update items in list', () async {
      await notifier.loadItems(['item1', 'item2', 'item3']);
      
      notifier.updateItem((item) => item == 'item2', 'updated_item2');
      
      expect(notifier.data, ['item1', 'updated_item2', 'item3']);
    });

    test('should filter items correctly', () async {
      await notifier.loadItems(['apple', 'banana', 'apricot']);
      
      notifier.filterItems((item) => item.startsWith('ap'));
      
      expect(notifier.data, ['apple', 'apricot']);
    });

    test('should sort items correctly', () async {
      await notifier.loadItems(['banana', 'apple', 'cherry']);
      
      notifier.sortItems((a, b) => a.compareTo(b));
      
      expect(notifier.data, ['apple', 'banana', 'cherry']);
    });

    test('should handle operations on empty state gracefully', () {
      // These operations should not throw when there's no data
      notifier.addItem('test');
      notifier.removeItem('test');
      notifier.updateItem((item) => true, 'test');
      notifier.filterItems((item) => true);
      notifier.sortItems((a, b) => 0);
      
      // State should remain unchanged
      expect(notifier.hasData, false);
    });
  });
}