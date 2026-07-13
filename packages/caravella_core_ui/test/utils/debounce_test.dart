import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/utils/debounce.dart';

void main() {
  group('Debouncer', () {
    test('runs the callback once after the duration elapses', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 20));
      var callCount = 0;

      debouncer.call(() => callCount++);

      expect(callCount, 0);
      await Future.delayed(const Duration(milliseconds: 40));
      expect(callCount, 1);
    });

    test('collapses rapid successive calls into a single execution', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 20));
      var callCount = 0;

      debouncer.call(() => callCount++);
      debouncer.call(() => callCount++);
      debouncer.call(() => callCount++);

      await Future.delayed(const Duration(milliseconds: 40));
      expect(callCount, 1);
    });

    test('cancel prevents the pending callback from running', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 20));
      var called = false;

      debouncer.call(() => called = true);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 40));
      expect(called, false);
    });

    test('dispose cancels any pending execution', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 20));
      var called = false;

      debouncer.call(() => called = true);
      debouncer.dispose();

      await Future.delayed(const Duration(milliseconds: 40));
      expect(called, false);
    });

    test('a later call resets the timer for an earlier one', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 30));
      final order = <String>[];

      debouncer.call(() => order.add('first'));
      await Future.delayed(const Duration(milliseconds: 15));
      debouncer.call(() => order.add('second'));

      await Future.delayed(const Duration(milliseconds: 40));
      expect(order, ['second']);
    });
  });
}
