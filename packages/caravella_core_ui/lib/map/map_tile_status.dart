import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// What the map shows of its tiles, for the messages over it.
enum MapTileState {
  /// Loading, not for long enough to say so.
  waiting,

  /// Still nothing after [MapTileStatus.slowAfter].
  slow,

  /// Tiles are showing.
  ready,

  /// Tiles failed and none is showing.
  unavailable,
}

/// Follows a map's tiles, so a screen can say why it is empty.
///
/// Give it to [StandardMap] and show [MapLoadingOverlay] and
/// [MapUnavailableCard] with it. A failure next to tiles that just loaded is
/// ignored: part of the map is there, for instance from the cache.
class MapTileStatus extends ChangeNotifier {
  final Duration slowAfter;
  final Duration recentLoad;

  MapTileStatus({
    this.slowAfter = const Duration(milliseconds: 1500),
    this.recentLoad = const Duration(seconds: 2),
  }) {
    _startWaiting();
  }

  final StreamController<void> _reset = StreamController<void>.broadcast();
  MapTileState _state = MapTileState.waiting;
  Timer? _slowTimer;
  DateTime? _lastLoad;
  bool _disposed = false;

  MapTileState get state => _state;

  /// Tells the tile layer to load its tiles again.
  Stream<void> get reset => _reset.stream;

  /// A tile is showing. Called while the tiles build, so listeners hear of
  /// it after the frame.
  void tileLoaded() {
    _lastLoad = DateTime.now();
    if (_state == MapTileState.ready) return;
    _slowTimer?.cancel();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _set(MapTileState.ready);
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void tileFailed() {
    final lastLoad = _lastLoad;
    if (lastLoad != null && DateTime.now().difference(lastLoad) < recentLoad) {
      return;
    }
    _slowTimer?.cancel();
    _set(MapTileState.unavailable);
  }

  void retry() {
    _lastLoad = null;
    _set(MapTileState.waiting);
    _startWaiting();
    _reset.add(null);
  }

  void _startWaiting() {
    _slowTimer?.cancel();
    _slowTimer = Timer(slowAfter, () => _set(MapTileState.slow));
  }

  void _set(MapTileState state) {
    if (_disposed || _state == state) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _slowTimer?.cancel();
    _reset.close();
    super.dispose();
  }
}
