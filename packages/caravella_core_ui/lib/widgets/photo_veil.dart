import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// A group photo that melts into a surface: in full color at the top, fading
/// into [color] towards the bottom, where the text sits on the plain surface
/// with the theme's colors (Home card, group page, Groups cards).
///
/// Measured from the bottom: the last [solidExtent] px are [color] (the text
/// goes there), and the photo fades into it over the [fadeExtent] px above.
/// With [topShade] a light scrim sits at the very top, for status bar icons
/// drawn over the photo.
class PhotoVeil extends StatelessWidget {
  /// Scrim at the very top with [topShade].
  static const double topShadeAlpha = 0.3;

  final String path;

  /// The surface the photo melts into.
  final Color color;

  final double solidExtent;
  final double fadeExtent;
  final bool topShade;

  const PhotoVeil({
    super.key,
    required this.path,
    required this.color,
    this.solidExtent = 0,
    this.fadeExtent = 120,
    this.topShade = false,
  });

  /// The fade gradient for a veil [height] px tall.
  LinearGradient gradientFor(double height) {
    final h = height <= 0 ? 1.0 : height;
    final clear = color.withValues(alpha: 0);
    final solidTop = h - solidExtent;
    final fadeTop = solidTop - fadeExtent;

    final colors = <Color>[];
    final stops = <double>[];
    void add(Color c, double y) {
      final stop = (y / h).clamp(0.0, 1.0);
      // Keep the stops in order when the veil is shorter than its parts.
      stops.add(stops.isEmpty || stop >= stops.last ? stop : stops.last);
      colors.add(c);
    }

    if (topShade) {
      add(Colors.black.withValues(alpha: topShadeAlpha), 0);
      add(Colors.black.withValues(alpha: 0), 96);
    } else {
      add(clear, 0);
    }
    // Smoothstep: starts and ends gently, so no edge shows where the photo
    // begins to fade or where the surface takes over.
    const steps = 8;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final eased = t * t * (3 - 2 * t);
      add(color.withValues(alpha: eased), fadeTop + fadeExtent * t);
    }
    add(color, h);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(path),
          fit: BoxFit.cover,
          // A photo that can't be read (deleted, moved) leaves the surface.
          errorBuilder: (_, _, _) => ColoredBox(color: color),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradientFor(constraints.maxHeight),
          ),
        ),
      ],
    ),
  );
}
