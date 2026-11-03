/// Why a sync exchange, or one group in it, didn't go through.
enum SyncProblemReason {
  /// The peer sent a group this device doesn't share with it.
  notShared,

  /// A group (or the whole delta) couldn't be read: usually different app
  /// versions on the two devices.
  unreadable,

  /// The peer isn't paired any more (no key on file): pair it again.
  notPaired,

  /// The peer answered with an error.
  peerError,

  /// The cloud (Google Drive) couldn't be reached.
  cloudUnreachable,

  /// Anything else.
  failed,
}

/// One thing that went wrong in sync, for Settings → Sync's "To fix" list
/// and the history: which device ([peerId], [peerName] when known), which
/// group when it's about one ([groupId]), why ([reason]) and when ([at]).
class SyncProblem {
  final SyncProblemReason reason;
  final String channel;
  final String peerId;
  final String? peerName;
  final String? groupId;
  final DateTime at;

  const SyncProblem({
    required this.reason,
    required this.channel,
    required this.peerId,
    required this.at,
    this.peerName,
    this.groupId,
  });

  SyncProblem copyWith({String? peerName}) => SyncProblem(
    reason: reason,
    channel: channel,
    peerId: peerId,
    at: at,
    peerName: peerName ?? this.peerName,
    groupId: groupId,
  );

  @override
  String toString() =>
      'SyncProblem($reason, channel: $channel, peer: $peerId'
      '${groupId == null ? '' : ', group: $groupId'})';
}
