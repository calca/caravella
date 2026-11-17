import 'package:material_ui/material_ui.dart';

/// Fades [child] in while it rises 10 px, after [delay]: Home's cards coming
/// in as the launch splash fades (see lib/main/startup_splash.dart).
///
/// Only at the app's start: once one entrance has played, later ones (a page
/// rebuilt, another group featured) show at once. Nothing moves with the
/// phone's animations turned off.
class StartupEntrance extends StatefulWidget {
  const StartupEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  static bool _played = false;

  @override
  State<StartupEntrance> createState() => _StartupEntranceState();
}

class _StartupEntranceState extends State<StartupEntrance>
    with SingleTickerProviderStateMixin {
  static const _move = Duration(milliseconds: 320);

  // The delay is part of the animation (no timer): tests settle it too.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + _move,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.delay.inMicroseconds / (widget.delay + _move).inMicroseconds,
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (StartupEntrance._played) {
      _controller.value = 1;
      return;
    }
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) StartupEntrance._played = true;
    });
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 10 * (1 - _curve.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
