import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';

/// How a [FormPill] looks.
enum FormPillStyle {
  /// A value that can be picked (raised surface, hairline border).
  normal,

  /// The picked value (filled in the text color, inverse label).
  selected,

  /// Something not set yet, to add (dashed border, muted label).
  add,
}

/// Rounded pill used in forms: choices (who paid, category), set values
/// (date, place) and things still to add (dashed). Monochrome: an optional
/// [icon] or [leading] widget, then [label].
class FormPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final FormPillStyle style;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Spoken label when it should differ from [label] (e.g. "Date: today").
  final String? semanticsLabel;
  final String? tooltip;

  const FormPill({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.style = FormPillStyle.normal,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
    this.tooltip,
  });

  /// Visual height; the touch target adds [touchMargin] above and below
  /// (48dp in all), so laid out with no run spacing the pills sit 8dp apart.
  static const double height = 40;
  static const double touchMargin = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final enabled = onTap != null;
    final selected = style == FormPillStyle.selected;
    final dashed = style == FormPillStyle.add;

    final background = switch (style) {
      FormPillStyle.selected => s.onSurface,
      FormPillStyle.normal => s.raisedSurface,
      FormPillStyle.add => Colors.transparent,
    };
    var foreground = switch (style) {
      FormPillStyle.selected => s.surface,
      FormPillStyle.normal => s.onSurface,
      FormPillStyle.add => s.onSurfaceVariant,
    };
    if (!enabled && !selected) {
      foreground = foreground.withValues(alpha: 0.6);
    }
    final borderColor = switch (style) {
      FormPillStyle.selected => s.onSurface,
      FormPillStyle.normal => s.outlineVariant.withValues(alpha: 0.6),
      FormPillStyle.add => s.outline.withValues(alpha: 0.7),
    };

    final hasLeading = leading != null || icon != null;
    final content = Padding(
      padding: EdgeInsets.only(left: hasLeading ? 6 : 14, right: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            SizedBox.square(dimension: 28, child: Center(child: leading)),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            SizedBox.square(
              dimension: 28,
              child: Icon(icon, size: 18, color: foreground),
            ),
            const SizedBox(width: 2),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    const shape = StadiumBorder();
    Widget pill = Material(
      color: background,
      shape: dashed
          ? shape
          : StadiumBorder(side: BorderSide(color: borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: height),
          child: Align(widthFactor: 1, heightFactor: 1, child: content),
        ),
      ),
    );
    if (dashed) {
      pill = CustomPaint(
        foregroundPainter: _DashedStadiumPainter(borderColor),
        child: pill,
      );
    }
    if (tooltip != null) pill = Tooltip(message: tooltip!, child: pill);

    return Semantics(
      button: enabled,
      selected: selected,
      enabled: enabled,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      onTap: onTap,
      // The margin around the pill is tappable too (48dp target).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: touchMargin),
          child: pill,
        ),
      ),
    );
  }
}

class _DashedStadiumPainter extends CustomPainter {
  final Color color;

  _DashedStadiumPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(0.5),
          Radius.circular(size.height / 2),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dash = 4.0, gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedStadiumPainter old) => old.color != color;
}

/// Small uppercase label above a group of form pills or fields, like the
/// labels above [SettingsGroup] cards.
class FormSectionLabel extends StatelessWidget {
  final String label;

  const FormSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Semantics(
        header: true,
        child: Text(
          label.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
