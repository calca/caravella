import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';

/// A ring filling up with how much of a budget is used: grey while within
/// it, full and muted amber once [over] (never red). Decorative: the widget
/// around it says the same in words for screen readers.
class BudgetRing extends StatelessWidget {
  /// 0 to 1; ignored when [over] (the ring is full).
  final double fraction;
  final bool over;
  final double size;
  final double strokeWidth;

  const BudgetRing({
    super.key,
    required this.fraction,
    this.over = false,
    this.size = 30,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            fraction: over ? 1 : fraction.clamp(0.0, 1.0),
            color: over ? s.budgetOver : s.budgetFill,
            track: over ? s.budgetOver : s.budgetTrack,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color track;
  final double strokeWidth;

  const _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(
      strokeWidth / 2 + size.width * 0.05,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      paint
        ..color = color
        ..strokeCap = fraction >= 1 ? StrokeCap.butt : StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}

/// A bar with how much of a budget is used, grey or muted amber when
/// [over], with an optional [marker] (0 to 1) for how far the period has
/// gone. Decorative: give it a label with [Semantics] where it matters.
class BudgetBar extends StatelessWidget {
  final double fraction;
  final bool over;
  final double? marker;
  final double height;

  const BudgetBar({
    super.key,
    required this.fraction,
    this.over = false,
    this.marker,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final value = over ? 1.0 : fraction.clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          return SizedBox(
            height: height + (marker == null ? 0 : 8),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: height,
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: s.budgetTrack,
                  ),
                ),
                if (value > 0)
                  Container(
                    height: height,
                    width: math.max(height, w * value),
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: over ? s.budgetOver : s.budgetFill,
                    ),
                  ),
                if (marker case final m?)
                  Positioned(
                    left: (w * m.clamp(0.0, 1.0) - 1).clamp(0.0, w - 2),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: s.onSurface,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
