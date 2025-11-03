import 'package:flutter/material.dart';

/// A unified TabBar widget with consistent styling across the app.
///
/// This widget provides a standard TabBar appearance matching the design
/// used in the history page, with consistent colors and indicator styling.
///
/// Example usage:
/// ```dart
/// DefaultTabController(
///   length: 2,
///   child: Column(
///     children: [
///       CaravellaTabBar(
///         tabs: [
///           Tab(text: 'Tab 1'),
///           Tab(text: 'Tab 2'),
///         ],
///       ),
///       Expanded(
///         child: TabBarView(
///           children: [
///             Center(child: Text('Content 1')),
///             Center(child: Text('Content 2')),
///           ],
///         ),
///       ),
///     ],
///   ),
/// )
/// ```
class CaravellaTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a CaravellaTabBar.
  ///
  /// The [tabs] parameter must not be null and its length must match the length
  /// of the [TabController.length] in the [controller] or the closest
  /// [DefaultTabController].
  const CaravellaTabBar({
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.tabAlignment,
    super.key,
  });

  /// The list of tabs to display.
  final List<Widget> tabs;

  /// The tab controller to use. If null, uses the closest [DefaultTabController].
  final TabController? controller;

  /// Whether the tab bar should be scrollable.
  ///
  /// When true, tabs can be scrolled horizontally if they exceed the width.
  /// Defaults to false.
  final bool isScrollable;

  /// How the tabs should be aligned when [isScrollable] is true.
  ///
  /// If null and [isScrollable] is true, defaults to [TabAlignment.start].
  /// If [isScrollable] is false, this parameter is ignored.
  final TabAlignment? tabAlignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TabBar(
      controller: controller,
      tabs: tabs,
      isScrollable: isScrollable,
      tabAlignment: tabAlignment,
      labelColor: colorScheme.onSurface,
      unselectedLabelColor: colorScheme.outline,
      indicatorColor: colorScheme.primary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
