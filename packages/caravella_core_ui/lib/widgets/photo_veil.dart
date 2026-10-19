import 'dart:io';

import 'package:material_ui/material_ui.dart';

/// A group photo seen through the card's own color: only hinted, so text on
/// it keeps the theme colors (Home card and Groups cards).
class PhotoVeil extends StatelessWidget {
  /// Opacity of [color] over the photo — the card color dominates, and
  /// `onSurface` text stays ≥4.5:1 even over a pure white or black photo.
  static const double alpha = 0.9;

  final String path;

  /// The card color the photo melts into.
  final Color color;

  const PhotoVeil({super.key, required this.path, required this.color});

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.file(
        File(path),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        // A photo that can't be read (deleted, moved) just leaves the veil.
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
      ColoredBox(color: color.withValues(alpha: alpha)),
    ],
  );
}
