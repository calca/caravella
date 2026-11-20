import 'package:material_ui/material_ui.dart';

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

  /// Where a Scaffold's floating action button goes so it stays at the
  /// bottom end corner of the [maxWidth] column instead of the window's.
  static FloatingActionButtonLocation fabLocation(double maxWidth) =>
      _ReadableEndFloat(maxWidth);

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

class _ReadableEndFloat extends StandardFabLocation
    with FabEndOffsetX, FabFloatOffsetY {
  final double maxWidth;

  const _ReadableEndFloat(this.maxWidth);

  @override
  double getOffsetX(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    final x = super.getOffsetX(scaffoldGeometry, adjustment);
    final side = (scaffoldGeometry.scaffoldSize.width - maxWidth) / 2;
    if (side <= 0) return x;
    return switch (scaffoldGeometry.textDirection) {
      TextDirection.ltr => x - side,
      TextDirection.rtl => x + side,
    };
  }
}
