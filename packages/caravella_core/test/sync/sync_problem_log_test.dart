import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// #606: what Settings → Sync lists under "To fix", and when it goes.
void main() {
  final t = DateTime.utc(2026, 11, 3, 10);

  SyncProblem problem(
    SyncProblemReason reason, {
    String peer = 'pixel',
    String? group,
  }) => SyncProblem(
    reason: reason,
    channel: 'lan',
    peerId: peer,
    groupId: group,
    at: t,
  );

  SyncResult result({
    String peer = 'pixel',
    Set<String> groups = const {},
    List<SyncProblem> problems = const [],
  }) => SyncResult(
    applied: 0,
    skipped: 0,
    errors: problems.length,
    channel: 'lan',
    peerId: peer,
    syncedAt: t,
    groupIds: groups,
    problems: problems,
  );

  test('an exchange\'s problems come in, newest first', () {
    final log = SyncProblemLog()
      ..noteResult(
        result(problems: [problem(SyncProblemReason.notShared, group: 'g1')]),
      )
      ..noteResult(
        result(
          peer: 'tablet',
          problems: [problem(SyncProblemReason.notPaired, peer: 'tablet')],
        ),
      );
    expect(log.problems.map((p) => p.peerId), ['tablet', 'pixel']);
  });

  test('a group carried cleanly later is fixed; others stay', () {
    final log = SyncProblemLog()
      ..noteResult(
        result(
          groups: {'g1', 'g2'},
          problems: [
            problem(SyncProblemReason.notShared, group: 'g1'),
            problem(SyncProblemReason.unreadable, group: 'g2'),
          ],
        ),
      )
      ..noteResult(result(groups: {'g1'}));
    expect(log.problems.single.groupId, 'g2');
  });

  test('the same device without that group leaves the problem', () {
    final log = SyncProblemLog()
      ..noteResult(
        result(problems: [problem(SyncProblemReason.notShared, group: 'g1')]),
      )
      ..noteResult(result(groups: {'g9'}));
    expect(log.problems, hasLength(1));
  });

  test('a whole-exchange problem goes when the device syncs again', () {
    final log = SyncProblemLog()
      ..noteResult(result(problems: [problem(SyncProblemReason.notPaired)]))
      ..noteResult(result(peer: 'other'));
    expect(log.problems, hasLength(1));
    log.noteResult(result());
    expect(log.problems, isEmpty);
  });

  test('the same problem again is listed once', () {
    final log = SyncProblemLog();
    for (var i = 0; i < 3; i++) {
      log.noteResult(
        result(
          groups: {'g1'},
          problems: [problem(SyncProblemReason.notShared, group: 'g1')],
        ),
      );
    }
    expect(log.problems, hasLength(1));
  });

  test('clearReason drops the cloud problem once Drive answers', () {
    final log = SyncProblemLog()
      ..noteResult(
        result(
          peer: 'cloud',
          problems: [
            problem(SyncProblemReason.cloudUnreachable, peer: 'cloud'),
          ],
        ),
      )
      ..clearReason(SyncProblemReason.cloudUnreachable);
    expect(log.problems, isEmpty);
  });
}
