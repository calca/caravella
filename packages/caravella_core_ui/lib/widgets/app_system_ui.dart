import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized widget for managing system UI overlay styles (status bar and navigation bar).
///
/// This widget provides a consistent way to set system UI colors across the app
/// with automatic dark/light mode adaptation.
///
/// Example usage:
/// ```dart
/// AppSystemUI(
///   child: Scaffold(...),
/// )
///
/// // Custom navigation bar color
/// AppSystemUI(
///   navigationBarColor: theme.colorScheme.surfaceContainer,
///   child: Scaffold(...),
/// )
/// ```
class AppSystemUI extends StatelessWidget {
  /// The child widget to wrap with system UI styling
  final Widget child;

  /// Custom color for the navigation bar. If null, uses [ColorScheme.surface]
  final Color? navigationBarColor;

  /// Custom color for the status bar. If null, uses transparent
  final Color? statusBarColor;

  /// Overrides status bar icon brightness regardless of theme: `true` forces
  /// light (white) icons, `false` forces dark icons, `null` follows the
  /// current theme's brightness.
  final bool? forceStatusBarLight;

  /// Overrides navigation bar icon brightness regardless of theme: `true`
  /// forces light (white) icons, `false` forces dark icons, `null` follows
  /// the current theme's brightness.
  final bool? forceNavigationBarLight;

  const AppSystemUI({
    super.key,
    required this.child,
    this.navigationBarColor,
    this.statusBarColor,
    this.forceStatusBarLight,
    this.forceNavigationBarLight,
  });

  /// Creates an AppSystemUI with surface navigation bar (default for most screens)
  factory AppSystemUI.surface({Key? key, required Widget child}) {
    return AppSystemUI(key: key, child: child);
  }

  /// Creates an AppSystemUI with surfaceContainer navigation bar (for home screen)
  factory AppSystemUI.surfaceContainer({
    Key? key,
    required Widget child,
    required BuildContext context,
  }) {
    return AppSystemUI(
      key: key,
      navigationBarColor: Theme.of(context).colorScheme.surfaceContainer,
      child: child,
    );
  }

  /// Creates an AppSystemUI with custom gradient navigation bar
  factory AppSystemUI.custom({
    Key? key,
    required Widget child,
    required Color navigationBarColor,
    bool? forceNavigationBarLight,
  }) {
    return AppSystemUI(
      key: key,
      navigationBarColor: navigationBarColor,
      forceNavigationBarLight: forceNavigationBarLight,
      child: child,
    );
  }

  /// Computes the [SystemUiOverlayStyle] this widget would apply via its
  /// [AnnotatedRegion], for reuse where a widget (e.g. an [AppBar]'s
  /// `systemOverlayStyle`) needs to match it exactly instead of falling back
  /// to that widget's own brightness auto-detection.
  static SystemUiOverlayStyle resolveStyle(
    BuildContext context, {
    Color? navigationBarColor,
    Color? statusBarColor,
    bool? forceStatusBarLight,
    bool? forceNavigationBarLight,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveNavBarColor =
        navigationBarColor ?? theme.colorScheme.surface;

    final statusBarIconBrightness = forceStatusBarLight == null
        ? (isDarkMode ? Brightness.light : Brightness.dark)
        : (forceStatusBarLight ? Brightness.light : Brightness.dark);

    final navBarIconBrightness = forceNavigationBarLight == null
        ? (isDarkMode ? Brightness.light : Brightness.dark)
        : (forceNavigationBarLight ? Brightness.light : Brightness.dark);

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor ?? Colors.transparent,
      statusBarIconBrightness: statusBarIconBrightness,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: effectiveNavBarColor,
      systemNavigationBarIconBrightness: navBarIconBrightness,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: resolveStyle(
        context,
        navigationBarColor: navigationBarColor,
        statusBarColor: statusBarColor,
        forceStatusBarLight: forceStatusBarLight,
        forceNavigationBarLight: forceNavigationBarLight,
      ),
      child: child,
    );
  }
}
