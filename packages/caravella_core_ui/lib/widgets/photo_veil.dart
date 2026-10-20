import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// A group photo shown as a cover: in full color at the top, darkening behind
/// the white text that sits on it near the bottom, then (optionally) melting
/// into [color] for the part of the surface that keeps the theme's text
/// colors (Home card, group page, Groups cards).
///
/// Measured from the bottom: the last [solidExtent] px are [color], the
/// [textExtent] px above them carry the full [scrimAlpha] scrim, and the
/// scrim fades in over the [rampExtent] px above that. With [topShade] a light
/// scrim also sits at the very top, for status bar icons drawn over it.
class PhotoVeil extends StatelessWidget {
  /// Black scrim behind on-photo text: white text stays ≥4.5:1 even over a
  /// pure white photo.
  static const double scrimAlpha = 0.55;

  /// Scrim at the very top with [topShade].
  static const double topShadeAlpha = 0.3;

  /// Text color on the photo.
  static const Color onPhoto = Colors.white;

  final String path;

  /// The surface the photo melts into at the bottom.
  final Color color;

  final double textExtent;
  final double rampExtent;
  final double solidExtent;
  final bool topShade;

  const PhotoVeil({
    super.key,
    required this.path,
    required this.color,
    this.textExtent = 96,
    this.rampExtent = 72,
    this.solidExtent = 0,
    this.topShade = false,
  });

  /// The scrim gradient for a veil [height] px tall.
  LinearGradient gradientFor(double height) {
    final h = height <= 0 ? 1.0 : height;
    double at(double y) => (y / h).clamp(0.0, 1.0);
    final scrim = Colors.black.withValues(alpha: scrimAlpha);
    final clear = Colors.black.withValues(alpha: 0);

    final solidTop = h - solidExtent;
    final textTop = solidTop - textExtent;
    final rampTop = textTop - rampExtent;

    final colors = <Color>[];
    final stops = <double>[];
    void add(Color c, double y) {
      final stop = at(y);
      // Keep the stops in order when the veil is shorter than its parts.
      stops.add(stops.isEmpty ? stop : (stop < stops.last ? stops.last : stop));
      colors.add(c);
    }

    if (topShade) {
      add(Colors.black.withValues(alpha: topShadeAlpha), 0);
      add(clear, 96);
    } else {
      add(clear, 0);
    }
    add(clear, rampTop);
    add(scrim, textTop);
    if (solidExtent > 0) {
      add(scrim, solidTop - 16);
      add(color, solidTop + 8);
      add(color, h);
    } else {
      add(scrim, h);
    }
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
