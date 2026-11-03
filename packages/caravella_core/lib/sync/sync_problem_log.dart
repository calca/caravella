import 'package:caravella_core/sync/models/sync_problem.dart';
import 'package:caravella_core/sync/models/sync_result.dart';

/// The sync problems not solved yet, newest first ([problems]).
///
/// Each exchange's [SyncResult] updates it ([noteResult]): its problems
/// come in; a group's problem with a device goes when a later exchange with
/// that device carries the group cleanly; a whole-exchange problem (no
/// group: not paired, the peer's error) goes when an exchange with that
/// device goes through. The same problem again replaces the older one.
/// Kept in memory, like the sync history.
class SyncProblemLog {
  static const int maxProblems = 20;

  final List<SyncProblem> _problems = [];

  List<SyncProblem> get problems => List.unmodifiable(_problems);

  void noteResult(SyncResult result) {
    final stillWrong = {for (final p in result.problems) p.groupId};
    _problems.removeWhere(
      (p) =>
          p.peerId == result.peerId &&
          (p.groupId == null ||
              (result.groupIds.contains(p.groupId) &&
                  !stillWrong.contains(p.groupId))),
    );
    for (final p in result.problems.reversed) {
      _add(p);
    }
  }

  /// Every problem with this [reason] is over (e.g. the cloud answered).
  void clearReason(SyncProblemReason reason) =>
      _problems.removeWhere((p) => p.reason == reason);

  void _add(SyncProblem problem) {
    _problems.removeWhere(
      (p) =>
          p.peerId == problem.peerId &&
          p.groupId == problem.groupId &&
          p.reason == problem.reason,
    );
    _problems.insert(0, problem);
    if (_problems.length > maxProblems) {
      _problems.removeRange(maxProblems, _problems.length);
    }
  }
}
