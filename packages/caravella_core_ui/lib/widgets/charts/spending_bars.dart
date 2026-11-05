import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../themes/app_radius.dart';

/// Spending per step (day, week or month) as bars starting from zero, one
/// per step, with a short mark for the steps without spending.
///
/// Reads the same with a single day of expenses or a whole trip, and with
/// amounts that are all alike. A few bars stay narrow and centered; with up
/// to [maxLabelledBars] of them each shows its amount (see [amountLabel]).
class SpendingBars extends StatelessWidget {
  /// Beyond this many bars the amounts no longer fit above them.
  static const int maxLabelledBars = 7;

  static const double _maxBarWidth = 44;
  static const double _maxGap = 6;
  static const double _minBarHeight = 6;
  static const double _emptyHeight = 3;
  static const double _labelGap = 4;

  /// Amounts per step, oldest first.
  final List<double> values;

  /// Accessibility description of the chart.
  final String semanticLabel;

  final double height;

  /// Bar color; defaults to `primary`.
  final Color? color;

  /// Text above a bar; without it no amounts are shown.
  final String Function(double value)? amountLabel;

  const SpendingBars({
    super.key,
    required this.values,
    required this.semanticLabel,
    this.height = 96,
    this.color,
    this.amountLabel,
  });

  /// Key of the bar at [index], for tests.
  static Key barKey(int index) => ValueKey('spending-bar-$index');

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(0, math.max);
    if (maxValue <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall;
    final label = values.length <= maxLabelledBars ? amountLabel : null;
    final labelHeight = label == null
        ? 0.0
        : MediaQuery.textScalerOf(context).scale(labelStyle?.fontSize ?? 11) *
              1.4;
    final barRoom = math.max(
      height - labelHeight - (label == null ? 0 : _labelGap),
      _minBarHeight,
    );

    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = math.min(
              constraints.maxWidth / values.length,
              _maxBarWidth + _maxGap,
            );
            final barWidth = slot - math.min(_maxGap, slot * 0.25);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++)
                  SizedBox(
                    width: slot,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label != null && values[i] > 0) ...[
                          SizedBox(
                            height: labelHeight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label(values[i]),
                                maxLines: 1,
                                style: labelStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: _labelGap),
                        ],
                        Container(
                          key: barKey(i),
                          width: barWidth,
                          height: values[i] > 0
                              ? math.max(
                                  values[i] / maxValue * barRoom,
                                  _minBarHeight,
                                )
                              : _emptyHeight,
                          decoration: BoxDecoration(
                            color: values[i] > 0
                                ? color ?? s.primary
                                : s.outlineVariant,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                math.min(AppRadius.sm, barWidth / 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
