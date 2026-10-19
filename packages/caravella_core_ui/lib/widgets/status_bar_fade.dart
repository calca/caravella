import 'package:material_ui/material_ui.dart';

/// Fade behind the status bar for edge-to-edge pages: content scrolling
/// under the clock dims into [color] (mostly opaque at the very top, so the
/// status icons stay readable) instead of being cut by a solid strip.
///
/// Place it at the top of a [Stack] over the scrolling content.
class StatusBarFade extends StatelessWidget {
  /// The page color the content fades into.
  final Color color;

  /// How far the fade extends below the status bar.
  final double extent;

  const StatusBarFade({super.key, required this.color, this.extent = 24});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top == 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: Container(
        height: top + extent,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.92),
              color.withValues(alpha: 0.75),
              color.withValues(alpha: 0),
            ],
            stops: [0, top / (top + extent), 1],
          ),
        ),
      ),
    );
  }
}
