import 'package:flutter/widgets.dart';

/// Width classes of the window, as in Material 3: what decides whether the
/// app shows its phone layout or a wider one. Use [WindowSize.of] instead of
/// comparing widths by hand, so every screen switches at the same points.
enum WindowSize {
  /// Under 600 dp: phones in portrait. The layout the app is designed for.
  compact,

  /// 600–839 dp: small tablets, foldables, phones in landscape, narrow
  /// browser windows.
  medium,

  /// 840 dp and more: tablets in landscape, desktop browsers.
  expanded;

  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 840;

  static WindowSize forWidth(double width) => width >= expandedMinWidth
      ? expanded
      : width >= mediumMinWidth
      ? medium
      : compact;

  /// The class of the current window (rebuilds only when its size changes).
  static WindowSize of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == compact;
}
