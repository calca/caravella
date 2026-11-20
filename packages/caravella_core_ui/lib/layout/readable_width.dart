import 'package:flutter/widgets.dart';

/// Keeps a page's content to a comfortable width on wide windows (tablets,
/// desktop browsers): centered, with the page's background on both sides.
/// On phones — any window no wider than [maxWidth] — it changes nothing.
///
/// It only adds side padding, so the child keeps the full height and the
/// same constraints shape it has on a phone (a ListView or Stack body still
/// fills the page).
class ReadableWidth extends StatelessWidget {
  /// Forms, settings, searches: one column of fields or rows.
  static const double text = 720;

  /// Home and a group's page: cards, lists and their header.
  static const double content = 960;

  /// Grids of cards or photos (Groups, photo search).
  static const double wide = 1200;

  final double maxWidth;
  final Widget child;

  const ReadableWidth({super.key, this.maxWidth = text, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite || width <= maxWidth) return child;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: (width - maxWidth) / 2),
          child: child,
        );
      },
    );
  }
}
