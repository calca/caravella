import 'package:material_ui/material_ui.dart';

/// A calm spending chart: one soft curve over the period, no figures, with a
/// dot on the last point and the period's two ends written below.
///
/// Meant for the rhythm of spending, not for reading amounts (Home card).
class SpendingWave extends StatelessWidget {
  /// Amounts per step (day, week or month), oldest first.
  final List<double> values;

  /// Label under the first point.
  final String startLabel;

  /// Label under the last point.
  final String endLabel;

  /// Accessibility description of the chart.
  final String? semanticLabel;

  final double height;

  /// Fill under the curve, fading out downwards; defaults to a translucent
  /// `onSurface`, so it takes on the card's color (a group's color too).
  final Color? fillColor;

  /// Curve color; defaults to a translucent `onSurface`.
  final Color? lineColor;

  /// Last point color; defaults to `primary`.
  final Color? dotColor;

  const SpendingWave({
    super.key,
    required this.values,
    required this.startLabel,
    required this.endLabel,
    this.semanticLabel,
    this.height = 48,
    this.fillColor,
    this.lineColor,
    this.dotColor,
  });

  /// Whether [values] have enough to draw: at least two steps with spending.
  static bool canShow(List<double> values) =>
      values.length >= 2 && values.where((v) => v > 0).length >= 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: s.onSurfaceVariant,
    );
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            child: CustomPaint(
              painter: SpendingWavePainter(
                values: values,
                fill: fillColor ?? s.onSurface.withValues(alpha: 0.12),
                line: lineColor ?? s.onSurface.withValues(alpha: 0.45),
                dot: dotColor ?? s.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(startLabel, style: labelStyle),
              Text(endLabel, style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paints [SpendingWave]: a smoothed curve through the values, scaled to the
/// highest one, with a filled area under it and a dot on the last point.
class SpendingWavePainter extends CustomPainter {
  final List<double> values;
  final Color fill;
  final Color line;
  final Color dot;

  static const double dotRadius = 3.5;

  SpendingWavePainter({
    required this.values,
    required this.fill,
    required this.line,
    required this.dot,
  });

  /// The points of the curve in a [size] box, leaving room for the dot.
  List<Offset> pointsFor(Size size) {
    if (values.isEmpty) return const [];
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    const pad = dotRadius + 1;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final step = values.length == 1 ? 0.0 : w / (values.length - 1);
    return [
      for (var i = 0; i < values.length; i++)
        Offset(
          pad + step * i,
          pad + h - (maxValue <= 0 ? 0 : values[i] / maxValue * h),
        ),
    ];
  }

  /// A smooth path through [points] (Catmull-Rom as cubic Béziers).
  static Path curveThrough(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    // Keep the curve inside the box (no overshoot below zero).
    final bottom = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i == 0 ? 0 : i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = points[i + 2 < points.length ? i + 2 : i + 1];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(
        c1.dx,
        c1.dy.clamp(double.negativeInfinity, bottom),
        c2.dx,
        c2.dy.clamp(double.negativeInfinity, bottom),
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final points = pointsFor(size);
    if (points.length < 2) return;
    final curve = curveThrough(points);
    final area = Path.from(curve)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    // Translucent and fading downwards: no hard grey block on a colored card.
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fill, fill.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      curve,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(points.last, dotRadius, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(SpendingWavePainter old) =>
      old.fill != fill ||
      old.line != line ||
      old.dot != dot ||
      !_sameValues(old.values, values);

  static bool _sameValues(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
