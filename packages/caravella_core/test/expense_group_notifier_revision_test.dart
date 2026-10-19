import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('revision keeps growing after a listener clears the queues', () {
    final notifier = ExpenseGroupNotifier();
    // Like Home in the app shell: the first listener consumes the queue.
    notifier.addListener(notifier.clearUpdatedGroups);
    final seen = <int>[];
    notifier.addListener(() => seen.add(notifier.revision));

    notifier.notifyGroupUpdated('a');
    notifier.notifyGroupUpdated('a');
    notifier.notifyGroupDeleted('b');

    expect(notifier.updatedGroupIds, isEmpty);
    expect(seen.where((r) => r > 0).toSet().length, 3);
  });
}
