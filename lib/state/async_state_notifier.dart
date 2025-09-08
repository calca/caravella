import 'package:flutter/foundation.dart';
import 'async_state.dart';

/// A ChangeNotifier that manages AsyncValue states
/// Provides a robust pattern for handling async operations with proper state management
abstract class AsyncStateNotifier<T> extends ChangeNotifier {
  AsyncValue<T> _value = const AsyncValue.idle();
  
  /// Current async value
  AsyncValue<T> get value => _value;
  
  /// Convenience getter for the data when available
  T? get data => _value.data;
  
  /// Convenience getter for loading state
  bool get isLoading => _value.isLoading;
  
  /// Convenience getter for error state
  bool get hasError => _value.hasError;
  
  /// Convenience getter for data availability
  bool get hasData => _value.hasData;
  
  /// Updates the current value and notifies listeners
  @protected
  void setValue(AsyncValue<T> newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
  
  /// Executes an async operation and manages the state transitions
  /// Automatically handles loading, success, and error states
  Future<void> execute(Future<T> Function() operation) async {
    setValue(const AsyncValue.loading());
    
    try {
      final result = await operation();
      setValue(AsyncValue.success(result));
    } catch (error, stackTrace) {
      setValue(AsyncValue.error(error, stackTrace));
      
      // Log error for debugging (can be customized per implementation)
      if (kDebugMode) {
        debugPrint('AsyncStateNotifier error: $error');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Executes an async operation without changing the loading state
  /// Useful for background updates that shouldn't show loading indicators
  Future<void> executeInBackground(Future<T> Function() operation) async {
    try {
      final result = await operation();
      setValue(AsyncValue.success(result));
    } catch (error, stackTrace) {
      setValue(AsyncValue.error(error, stackTrace));
      
      if (kDebugMode) {
        debugPrint('AsyncStateNotifier background error: $error');
      }
    }
  }
  
  /// Resets the state to idle
  void reset() {
    setValue(const AsyncValue.idle());
  }
  
  /// Sets the state to success with the provided data
  void setData(T data) {
    setValue(AsyncValue.success(data));
  }
  
  /// Sets the state to error with the provided error
  void setError(Object error, StackTrace stackTrace) {
    setValue(AsyncValue.error(error, stackTrace));
  }
  
  /// Transforms the current data using the provided function
  /// If there's no data or an error occurs, the state is updated accordingly
  void transformData(T Function(T data) transform) {
    if (hasData) {
      try {
        final newData = transform(data as T);
        setValue(AsyncValue.success(newData));
      } catch (error, stackTrace) {
        setValue(AsyncValue.error(error, stackTrace));
      }
    }
  }
}

/// A specialized AsyncStateNotifier for managing lists
abstract class AsyncListNotifier<T> extends AsyncStateNotifier<List<T>> {
  /// Adds an item to the current list if data is available
  void addItem(T item) {
    if (hasData) {
      final currentList = List<T>.from(data!);
      currentList.add(item);
      setData(currentList);
    }
  }
  
  /// Removes an item from the current list if data is available
  void removeItem(T item) {
    if (hasData) {
      final currentList = List<T>.from(data!);
      currentList.remove(item);
      setData(currentList);
    }
  }
  
  /// Updates an item in the current list if data is available
  void updateItem(bool Function(T) predicate, T newItem) {
    if (hasData) {
      final currentList = List<T>.from(data!);
      final index = currentList.indexWhere(predicate);
      if (index != -1) {
        currentList[index] = newItem;
        setData(currentList);
      }
    }
  }
  
  /// Filters the current list if data is available
  void filterItems(bool Function(T) predicate) {
    if (hasData) {
      final filteredList = data!.where(predicate).toList();
      setData(filteredList);
    }
  }
  
  /// Sorts the current list if data is available
  void sortItems(int Function(T, T) compare) {
    if (hasData) {
      final sortedList = List<T>.from(data!);
      sortedList.sort(compare);
      setData(sortedList);
    }
  }
}